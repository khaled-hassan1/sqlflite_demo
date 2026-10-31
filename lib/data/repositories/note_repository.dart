import '../../core/constants/app_strings.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../datasources/media_storage.dart';
import '../datasources/note_local_source.dart';
import '../models/attachment.dart';
import '../models/checklist_item.dart';
import '../models/note.dart';

/// Contract used by the presentation layer; hides storage details.
abstract interface class NoteRepository {
  Future<List<Note>> loadAll();
  Future<void> save(Note note);
  Future<void> saveAll(Iterable<Note> notes);

  /// Removes notes and their media files from disk for good.
  Future<void> deleteForever(Iterable<Note> notes);

  /// Saves an unpinned copy of [note] (with copies of its media files).
  Future<Note> duplicate(Note note);
}

final class LocalNoteRepository implements NoteRepository {
  const LocalNoteRepository(this._source, this._media);

  final NoteLocalSource _source;
  final MediaStorage _media;

  static AppException Function(Object, StackTrace) _storage(String message) =>
      (Object e, StackTrace s) =>
          StorageException(message, cause: e, stackTrace: s);

  @override
  Future<List<Note>> loadAll() =>
      ErrorHandler.guard(_source.readAll, _storage(AppStrings.errorLoad));

  @override
  Future<void> save(Note note) => ErrorHandler.guard(
    () => _source.put(note),
    _storage(AppStrings.errorSave),
  );

  @override
  Future<void> saveAll(Iterable<Note> notes) => ErrorHandler.guard(
    () => _source.putAll(notes),
    _storage(AppStrings.errorSave),
  );

  @override
  Future<void> deleteForever(Iterable<Note> notes) {
    return ErrorHandler.guard(() async {
      await _source.deleteAll(notes.map((Note n) => n.id));
      await _media.deleteFiles(
        notes
            .expand((Note n) => n.attachments)
            .map((Attachment a) => a.fileName),
      );
    }, _storage(AppStrings.errorDelete));
  }

  @override
  Future<Note> duplicate(Note note) async {
    final List<Attachment> copied = <Attachment>[];
    try {
      for (final Attachment a in note.attachments) {
        if (_media.exists(a)) copied.add(await _media.duplicate(a));
      }
      final Note blank = Note.create();
      final Note copy = blank.copyWith(
        title: note.title,
        content: note.content,
        color: note.color,
        isChecklist: note.isChecklist,
        checklist: List<ChecklistItem>.unmodifiable(
          note.checklist.map(
            (ChecklistItem i) =>
                ChecklistItem.create(i.text).copyWith(isDone: i.isDone),
          ),
        ),
        attachments: List<Attachment>.unmodifiable(copied),
        tags: note.tags,
      );
      await save(copy);
      return copy;
    } catch (_) {
      // Do not leave orphaned media behind when the copy fails.
      await _media.deleteFiles(copied.map((Attachment a) => a.fileName));
      rethrow;
    }
  }
}
