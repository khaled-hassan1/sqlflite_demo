import 'package:flutter/foundation.dart';

/// Top-level place the user is browsing.
enum NoteSection { notes, archive, trash }

/// Content filter shown as chips on the home screen.
enum NoteCategory { all, audio, checklists, attachments, drawings }

/// Immutable description of what the home screen shows.
@immutable
final class NoteQuery {
  const NoteQuery({
    this.section = NoteSection.notes,
    this.category = NoteCategory.all,
    this.tag,
  });

  final NoteSection section;
  final NoteCategory category;
  final String? tag;

  bool get isDefault =>
      section == NoteSection.notes &&
      category == NoteCategory.all &&
      tag == null;

  @override
  bool operator ==(Object other) =>
      other is NoteQuery &&
      other.section == section &&
      other.category == category &&
      other.tag == tag;

  @override
  int get hashCode => Object.hash(section, category, tag);
}
