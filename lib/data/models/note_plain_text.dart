import '../../core/constants/app_strings.dart';
import 'checklist_item.dart';
import 'note.dart';

/// Plain-text form of a note, used for sharing and copying.
extension NotePlainText on Note {
  String get plainText {
    final StringBuffer buffer = StringBuffer();
    if (title.trim().isNotEmpty) buffer.writeln(title.trim());

    if (isChecklist) {
      for (final ChecklistItem item in checklist) {
        if (item.isBlank) continue;
        final String box = item.isDone
            ? AppStrings.checkedBox
            : AppStrings.uncheckedBox;
        buffer.writeln('$box ${item.text.trim()}');
      }
    } else if (content.trim().isNotEmpty) {
      if (buffer.isNotEmpty) buffer.writeln();
      buffer.writeln(content.trim());
    }

    if (tags.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(
          tags.map((String t) => '${AppStrings.tagPrefix}$t').join(' '),
        );
    }
    return buffer.toString().trim();
  }
}
