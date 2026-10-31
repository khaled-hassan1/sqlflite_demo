import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'app_exception.dart';

typedef ExceptionFactory = AppException Function(
  Object error,
  StackTrace stackTrace,
);

/// Central place for logging errors and translating raw errors to
/// [AppException]s.
abstract final class ErrorHandler {
  static const String _logName = 'my_notes';

  /// Logs an error with its stack trace (debug console / logcat).
  static void log(Object error, [StackTrace? stackTrace, String? context]) {
    developer.log(
      context ?? 'Unhandled error',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  /// Runs [action]; any non-[AppException] error is logged and converted
  /// with [onError]. [AppException]s pass through untouched.
  static Future<T> guard<T>(
    Future<T> Function() action,
    ExceptionFactory onError,
  ) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      log(error, stackTrace);
      throw onError(error, stackTrace);
    }
  }

  /// Synchronous version of [guard].
  static T guardSync<T>(T Function() action, ExceptionFactory onError) {
    try {
      return action();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      log(error, stackTrace);
      throw onError(error, stackTrace);
    }
  }

  /// Installs global handlers for framework and uncaught async errors.
  static void installGlobalHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      log(details.exception, details.stack, 'FlutterError');
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      log(error, stack, 'PlatformDispatcher');
      return true;
    };
  }
}
