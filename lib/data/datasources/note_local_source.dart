import 'dart:convert';
import 'dart:isolate';

import 'package:hive_ce/hive.dart';

import '../../core/constants/app_config.dart';
import '../models/note.dart';

/// Persists notes as JSON strings in a Hive box (key = note id).
///
/// Storing JSON avoids generated type adapters and keeps the on-disk format
/// identical to the backup format.
final class NoteLocalSource {
  Box<String>? _box;

  Box<String> get _notes {
    final Box<String>? box = _box;
    if (box == null || !box.isOpen) {
      throw StateError('NoteLocalSource used before init()');
    }
    return box;
  }

  Future<void> init() async {
    _box ??= await Hive.openBox<String>(AppConfig.notesBox);
  }

  /// Decodes all notes; large collections are decoded on a background isolate.
  Future<List<Note>> readAll() async {
    final List<String> raw = _notes.values.toList(growable: false);
    if (raw.length < AppConfig.isolateDecodeThreshold) return _decode(raw);
    return Isolate.run(() => _decode(raw));
  }

  bool contains(String id) => _notes.containsKey(id);

  Future<void> put(Note note) => _notes.put(note.id, jsonEncode(note.toJson()));

  Future<void> putAll(Iterable<Note> notes) => _notes.putAll(<String, String>{
    for (final Note note in notes) note.id: jsonEncode(note.toJson()),
  });

  Future<void> delete(String id) => _notes.delete(id);

  Future<void> deleteAll(Iterable<String> ids) => _notes.deleteAll(ids);

  static List<Note> _decode(List<String> raw) {
    final List<Note> notes = <Note>[];
    for (final String json in raw) {
      try {
        notes.add(Note.fromJson(jsonDecode(json) as Map<String, dynamic>));
      } on Object {
        // A single corrupted record must not prevent the rest from loading.
        continue;
      }
    }
    return notes;
  }
}
