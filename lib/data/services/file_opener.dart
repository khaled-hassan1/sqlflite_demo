import 'dart:io';

import 'package:open_filex/open_filex.dart';

import '../../core/constants/app_strings.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';

/// Opens a local file with whatever app the system offers.
abstract final class FileOpener {
  static Future<void> open(String path) {
    return ErrorHandler.guard(
      () async {
        if (!File(path).existsSync()) {
          throw const MediaException(AppStrings.errorFileMissing);
        }
        final OpenResult result = await OpenFilex.open(path);
        if (result.type != ResultType.done) {
          throw MediaException(AppStrings.errorOpenFile, cause: result.message);
        }
      },
      (Object e, StackTrace s) =>
          MediaException(AppStrings.errorOpenFile, cause: e, stackTrace: s),
    );
  }
}
