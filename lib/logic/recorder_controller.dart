import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import '../core/constants/constants.dart';
import '../core/utils/formatters.dart';
import '../core/utils/safe_runner.dart';
import '../data/datasources/media_storage.dart';
import '../data/models/attachment.dart';
import '../data/services/audio_recorder_service.dart';

enum RecorderStatus { idle, recording, paused, saving }

/// State of the voice-recording sheet.
///
/// [elapsed] and [levels] tick ~11 times per second, so they are exposed as
/// [ValueNotifier]s; only [status] changes call [notifyListeners].
final class RecorderController extends ChangeNotifier with SafeRunner {
  RecorderController({required this._media, AudioRecorderService? service})
    : _service = service ?? AudioRecorderService();

  final MediaStorage _media;
  final AudioRecorderService _service;
  final Stopwatch _stopwatch = Stopwatch();

  final ValueNotifier<Duration> elapsed = ValueNotifier<Duration>(
    Duration.zero,
  );
  final ValueNotifier<List<double>> levels = ValueNotifier<List<double>>(
    List<double>.filled(AppConfig.liveWaveformBars, 0),
  );

  StreamSubscription<Amplitude>? _amplitudeSub;
  RecorderStatus _status = RecorderStatus.idle;
  String? _path;
  bool _disposed = false;

  RecorderStatus get status => _status;
  bool get isActive =>
      _status == RecorderStatus.recording || _status == RecorderStatus.paused;

  Future<void> start() async {
    if (_status != RecorderStatus.idle) return;
    final String path = _media.pathOf(
      _media.newFileName(AppConfig.recordingExtension),
    );
    final bool? started = await runSafe<bool>(() async {
      await _service.start(path);
      return true;
    });
    if (started == null || _disposed) return;
    _path = path;
    _stopwatch
      ..reset()
      ..start();
    _amplitudeSub = _service.amplitude().listen(_onAmplitude);
    _setStatus(RecorderStatus.recording);
  }

  Future<void> togglePause() async {
    if (_status == RecorderStatus.recording) {
      await runSafe(_service.pause);
      _stopwatch.stop();
      _setStatus(RecorderStatus.paused);
    } else if (_status == RecorderStatus.paused) {
      await runSafe(_service.resume);
      _stopwatch.start();
      _setStatus(RecorderStatus.recording);
    }
  }

  /// Stops recording and returns the saved attachment.
  Future<Attachment?> finish() async {
    if (!isActive) return null;
    _setStatus(RecorderStatus.saving);
    _stopwatch.stop();
    await _amplitudeSub?.cancel();
    final String? output = await runSafe<String?>(_service.stop);
    final String? path = output ?? _path;
    if (path == null) return null;
    final DateTime now = DateTime.now();
    final Attachment? attachment = await runSafe(
      () => _media.adopt(
        path,
        type: AttachmentType.audio,
        displayName:
            '${AppStrings.recordingPrefix} ${Formatters.relativeDate(now)}',
        duration: _stopwatch.elapsed,
      ),
    );
    _path = null;
    return attachment;
  }

  /// Stops recording and deletes the partial file.
  Future<void> discard() async {
    await _amplitudeSub?.cancel();
    _stopwatch.stop();
    if (isActive || _status == RecorderStatus.saving) {
      await runSafe(_service.cancel);
    }
    final String? path = _path;
    _path = null;
    if (path != null) await _media.deletePath(path);
    _setStatus(RecorderStatus.idle);
  }

  void _onAmplitude(Amplitude amp) {
    elapsed.value = _stopwatch.elapsed;
    // Map dBFS (-60..0) to 0..1.
    final double normalized =
        ((amp.current - AppConfig.silenceDb) / -AppConfig.silenceDb).clamp(
          0.05,
          1.0,
        );
    final List<double> next = List<double>.of(levels.value)
      ..removeAt(0)
      ..add(normalized);
    levels.value = next;
  }

  void _setStatus(RecorderStatus status) {
    if (_disposed || status == _status) return;
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_amplitudeSub?.cancel());
    // Anything still recording when the sheet closes is abandoned.
    final String? path = _path;
    unawaited(() async {
      if (path != null) {
        await runSafe(_service.cancel);
        await _media.deletePath(path);
      }
      await _service.dispose();
    }());
    elapsed.dispose();
    levels.dispose();
    super.dispose();
  }
}
