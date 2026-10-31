import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_config.dart';
import '../models/note.dart';

/// Reads notes saved by version 1.x of the app, which kept them in a sqflite
/// database (`sqflite.db`, table `notes`: id, title, description).
///
/// The old file is opened read-only and never modified or deleted, so the
/// original data stays on the device even if an import fails half-way.
final class LegacyNoteSource {
  const LegacyNoteSource();

  static final RegExp _nonAlphanumeric = RegExp('[^0-9A-Za-z]');

  /// Returns every old note converted to the new [Note] model, or an empty
  /// list when the app was never used before version 2.
  Future<List<Note>> readAll() async {
    final String path = join(await getDatabasesPath(), AppConfig.legacyDbName);
    if (!File(path).existsSync()) return const <Note>[];

    final Database db = await openReadOnlyDatabase(path);
    try {
      final List<Map<String, Object?>> tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: <Object>['table', AppConfig.legacyNotesTable],
      );
      if (tables.isEmpty) return const <Note>[];

      final List<Map<String, Object?>> rows = await db.query(
        AppConfig.legacyNotesTable,
      );
      return rows.map(fromRow).whereType<Note>().toList(growable: false);
    } finally {
      await db.close();
    }
  }

  /// Converts one old row. The old id was `DateTime.toString()` of the
  /// creation time, so it doubles as the creation date. The new id is
  /// derived from the old one, which makes re-running the import harmless.
  static Note? fromRow(Map<String, Object?> row) {
    final String oldId = (row['id'] as String?) ?? '';
    final String title = (row['title'] as String?) ?? '';
    final String content = (row['description'] as String?) ?? '';
    if (oldId.isEmpty || (title.trim().isEmpty && content.trim().isEmpty)) {
      return null;
    }

    final DateTime created = DateTime.tryParse(oldId) ?? DateTime.now();
    return Note(
      id:
          '${AppConfig.legacyIdPrefix}'
          '${oldId.replaceAll(_nonAlphanumeric, '')}',
      title: title,
      content: content,
      createdAt: created,
      updatedAt: created,
      sortOrder: created.millisecondsSinceEpoch.toDouble(),
    );
  }
}
