import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/constants.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';
import '../core/utils/safe_runner.dart';

/// One shared audio player for the whole app.
///
/// Coarse state (which file, playing or not, speed) notifies listeners;
/// high-frequency state ([position], [duration]) lives in [ValueNotifier]s so
/// only the progress widgets repaint while audio plays.
final class AudioPlaybackProvider extends ChangeNotifier with SafeRunner {
  AudioPlaybackProvider() : _player = AudioPlayer() {
    // Default `ReleaseMode.release` frees the source when a track ends, so a
    // later `resume()` would do nothing. `stop` keeps it loaded and rewinds.
    unawaited(_player.setReleaseMode(ReleaseMode.stop));
    _subscriptions.addAll(<StreamSubscription<dynamic>>[
      _player.onPositionChanged.listen((Duration p) => position.value = p),
      _player.onDurationChanged.listen((Duration d) => duration.value = d),
      _player.onPlayerStateChanged.listen(_onState),
      _player.onPlayerComplete.listen((_) => position.value = Duration.zero),
    ]);
  }

  final AudioPlayer _player;
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  final ValueNotifier<Duration> position = ValueNotifier<Duration>(
    Duration.zero,
  );
  final ValueNotifier<Duration> duration = ValueNotifier<Duration>(
    Duration.zero,
  );

  String? _currentPath;
  bool _isPlaying = false;
  double _speed = AppConfig.playbackSpeeds.first;

  String? get currentPath => _currentPath;
  bool get isPlaying => _isPlaying;
  double get speed => _speed;

  bool isCurrent(String path) => _currentPath == path;
  bool isPlayingPath(String path) => _isPlaying && _currentPath == path;

  /// Plays [path], or pauses/resumes it if it is already loaded.
  Future<void> toggle(String path) => runSafe(
    () => ErrorHandler.guard(() async {
      if (_currentPath == path) {
        if (_isPlaying) {
          await _player.pause();
        } else if (_player.state == PlayerState.paused) {
          await _player.resume();
        } else {
          // Finished or stopped: play again from the start.
          await _player.play(DeviceFileSource(path));
        }
        return;
      }
      if (!File(path).existsSync()) {
        throw const MediaException(AppStrings.errorFileMissing);
      }
      await _player.stop();
      position.value = Duration.zero;
      duration.value = Duration.zero;
      _currentPath = path;
      notifyListeners();
      await _player.setPlaybackRate(_speed);
      await _player.play(DeviceFileSource(path));
    }, _error),
  );

  Future<void> seek(Duration target) async {
    if (_currentPath == null) return;
    final Duration max = duration.value;
    final Duration clamped = target < Duration.zero
        ? Duration.zero
        : (max > Duration.zero && target > max ? max : target);
    await runSafe(
      () => ErrorHandler.guard(() => _player.seek(clamped), _error),
    );
  }

  Future<void> seekBy(Duration delta) => seek(position.value + delta);

  /// Seeks to a fraction (0..1) of the track.
  Future<void> seekFraction(double fraction) =>
      seek(duration.value * fraction.clamp(0.0, 1.0));

  Future<void> cycleSpeed() async {
    const List<double> speeds = AppConfig.playbackSpeeds;
    _speed = speeds[(speeds.indexOf(_speed) + 1) % speeds.length];
    notifyListeners();
    if (_currentPath != null) {
      await runSafe(
        () => ErrorHandler.guard(() => _player.setPlaybackRate(_speed), _error),
      );
    }
  }

  /// Stops playback if [path] is the loaded file (e.g. before deleting it).
  Future<void> release(String path) async {
    if (_currentPath != path) return;
    await stop();
  }

  Future<void> stop() async {
    await runSafe(() => ErrorHandler.guard(_player.stop, _error));
    _currentPath = null;
    _isPlaying = false;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    notifyListeners();
  }

  void _onState(PlayerState state) {
    final bool playing = state == PlayerState.playing;
    if (playing == _isPlaying) return;
    _isPlaying = playing;
    notifyListeners();
  }

  static AppException _error(Object e, StackTrace s) =>
      AudioException(AppStrings.errorPlayback, cause: e, stackTrace: s);

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> s in _subscriptions) {
      s.cancel();
    }
    _player.dispose();
    position.dispose();
    duration.dispose();
    super.dispose();
  }
}
