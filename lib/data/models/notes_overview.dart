import 'package:flutter/foundation.dart';

import 'note.dart';

/// Visible notes split into the "pinned" and "others" groups.
@immutable
final class NotesView {
  const NotesView({required this.pinned, required this.others});

  static const NotesView empty = NotesView(pinned: <Note>[], others: <Note>[]);

  final List<Note> pinned;
  final List<Note> others;

  bool get isEmpty => pinned.isEmpty && others.isEmpty;
  int get length => pinned.length + others.length;
}

/// Counters displayed in the navigation drawer.
@immutable
final class NoteCounts {
  const NoteCounts({
    this.notes = 0,
    this.audio = 0,
    this.checklists = 0,
    this.drawings = 0,
    this.archive = 0,
    this.trash = 0,
  });

  final int notes;
  final int audio;
  final int checklists;
  final int drawings;
  final int archive;
  final int trash;

  @override
  bool operator ==(Object other) =>
      other is NoteCounts &&
      other.notes == notes &&
      other.audio == audio &&
      other.checklists == checklists &&
      other.drawings == drawings &&
      other.archive == archive &&
      other.trash == trash;

  @override
  int get hashCode =>
      Object.hash(notes, audio, checklists, drawings, archive, trash);
}

/// A label and how many active notes use it.
@immutable
final class TagCount {
  const TagCount(this.tag, this.count);

  final String tag;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is TagCount && other.tag == tag && other.count == count;

  @override
  int get hashCode => Object.hash(tag, count);
}

/// Bytes used on disk, grouped the way the storage card shows them.
@immutable
final class StorageUsage {
  const StorageUsage({
    this.audioBytes = 0,
    this.imageBytes = 0,
    this.textBytes = 0,
  });

  final int audioBytes;
  final int imageBytes;
  final int textBytes;

  int get total => audioBytes + imageBytes + textBytes;

  @override
  bool operator ==(Object other) =>
      other is StorageUsage &&
      other.audioBytes == audioBytes &&
      other.imageBytes == imageBytes &&
      other.textBytes == textBytes;

  @override
  int get hashCode => Object.hash(audioBytes, imageBytes, textBytes);
}
