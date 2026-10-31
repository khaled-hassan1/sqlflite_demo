import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../models/note.dart';
import '../models/note_plain_text.dart';

/// Sends a note's text to other apps or to the clipboard.
final class ShareService {
  const ShareService();

  static AppException _error(Object e, StackTrace s) =>
      MediaException(AppStrings.errorShare, cause: e, stackTrace: s);

  /// Several notes are joined with a separator line.
  static String textOf(Iterable<Note> notes) => notes
      .map((Note n) => n.plainText)
      .where((String t) => t.isNotEmpty)
      .join(AppStrings.notesSeparator);

  Future<void> share(List<Note> notes) => ErrorHandler.guard(() {
    final String? subject =
        notes.length == 1 && notes.first.title.trim().isNotEmpty
        ? notes.first.title.trim()
        : null;
    return SharePlus.instance.share(
      ShareParams(text: textOf(notes), subject: subject),
    );
  }, _error);

  Future<void> copy(List<Note> notes) => ErrorHandler.guard(
    () => Clipboard.setData(ClipboardData(text: textOf(notes))),
    _error,
  );
}
