import 'package:record/record.dart';

import '../../core/constants/constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';

/// Thin wrapper around the `record` plugin with normalized errors.
final class AudioRecorderService {
  AudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;

  static const RecordConfig _config = RecordConfig(
    bitRate: AppConfig.recordingBitRate,
    sampleRate: AppConfig.recordingSampleRate,
    numChannels: 1,
  );

  Stream<Amplitude> amplitude() =>
      _recorder.onAmplitudeChanged(AppDurations.amplitudeInterval);

  Future<void> start(String path) => ErrorHandler.guard(() async {
    final bool granted = await _recorder.hasPermission();
    if (!granted) {
      throw const PermissionException(AppStrings.errorMicPermission);
    }
    await _recorder.start(_config, path: path);
  }, _error);

  Future<void> pause() => ErrorHandler.guard(_recorder.pause, _error);

  Future<void> resume() => ErrorHandler.guard(_recorder.resume, _error);

  /// Stops and returns the output path.
  Future<String?> stop() => ErrorHandler.guard(_recorder.stop, _error);

  Future<void> cancel() => ErrorHandler.guard(_recorder.cancel, _error);

  Future<void> dispose() => _recorder.dispose();

  static AppException _error(Object e, StackTrace s) =>
      AudioException(AppStrings.errorRecording, cause: e, stackTrace: s);
}
