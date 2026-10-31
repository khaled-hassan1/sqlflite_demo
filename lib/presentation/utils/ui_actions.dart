import '../../core/utils/safe_runner.dart';
import '../../data/services/file_opener.dart';

/// Fire-and-forget UI actions whose failures are reported via snack bar.
abstract final class UiActions {
  static final _Runner _runner = _Runner();

  static Future<void> openFile(String path) =>
      _runner.runSafe(() => FileOpener.open(path));
}

final class _Runner with SafeRunner {}
