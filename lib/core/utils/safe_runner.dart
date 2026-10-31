import '../errors/app_exception.dart';
import '../errors/error_handler.dart';
import 'app_messenger.dart';

/// Mixed into controllers/providers: executes an async action, and on
/// failure logs it and surfaces a friendly message instead of crashing.
mixin SafeRunner {
  Future<T?> runSafe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException catch (error) {
      ErrorHandler.log(error.cause ?? error, error.stackTrace, error.message);
      AppMessenger.error(error);
    } catch (error, stackTrace) {
      ErrorHandler.log(error, stackTrace);
      AppMessenger.error(error);
    }
    return null;
  }
}
