import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_demo/data/datasources/legacy_note_source.dart';
import 'package:sqlite_demo/data/models/note.dart';

void main() {
  group('LegacyNoteSource.fromRow', () {
    test('keeps title, body and creation date of a v1 note', () {
      final DateTime created = DateTime(2024, 3, 10, 9, 15, 0, 123);
      final Note? note = LegacyNoteSource.fromRow(<String, Object?>{
        'id': created.toString(),
        'title': 'قائمة المشتريات',
        'description': 'لبن\nبيض',
      });

      expect(note, isNotNull);
      expect(note!.title, 'قائمة المشتريات');
      expect(note.content, 'لبن\nبيض');
      expect(note.createdAt, created);
      expect(note.updatedAt, created);
      expect(note.isActive, isTrue);
    });

    test('produces the same id every time (import can be re-run)', () {
      final Map<String, Object?> row = <String, Object?>{
        'id': '2025-01-15 07:00:00.000',
        'title': 'a',
        'description': '',
      };
      expect(
        LegacyNoteSource.fromRow(row)!.id,
        LegacyNoteSource.fromRow(row)!.id,
      );
      expect(LegacyNoteSource.fromRow(row)!.id, 'legacy_20250115070000000');
    });

    test('accepts a note with only a title or only a body', () {
      expect(
        LegacyNoteSource.fromRow(<String, Object?>{
          'id': '2025-01-15 07:00:00.000',
          'title': '',
          'description': 'body',
        }),
        isNotNull,
      );
      expect(
        LegacyNoteSource.fromRow(<String, Object?>{
          'id': '2025-01-15 07:00:01.000',
          'title': 'title',
          'description': null,
        })!.content,
        '',
      );
    });

    test('skips empty rows and survives an unparsable id', () {
      expect(
        LegacyNoteSource.fromRow(<String, Object?>{
          'id': '2025-01-15 07:00:00.000',
          'title': ' ',
          'description': '',
        }),
        isNull,
      );
      expect(
        LegacyNoteSource.fromRow(<String, Object?>{
          'id': 'not-a-date',
          'title': 'x',
          'description': '',
        })!.id,
        'legacy_notadate',
      );
    });

    test('round-trips through the Hive JSON format', () {
      final Note note = LegacyNoteSource.fromRow(<String, Object?>{
        'id': '2024-06-01 20:40:05.123',
        'title': 'Meeting',
        'description': 'Call Ahmed',
      })!;
      final Note decoded = Note.fromJson(note.toJson());
      expect(decoded.id, note.id);
      expect(decoded.title, 'Meeting');
      expect(decoded.content, 'Call Ahmed');
      expect(decoded.createdAt, note.createdAt);
    });
  });
}
