import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_demo/data/models/checklist_item.dart';
import 'package:sqlite_demo/data/models/note.dart';
import 'package:sqlite_demo/data/models/note_plain_text.dart';

void main() {
  final Note base = Note.create();

  test('text note: title, blank line, body', () {
    expect(
      base.copyWith(title: ' Title ', content: 'Body\nline').plainText,
      'Title\n\nBody\nline',
    );
  });

  test('checklist note: boxes reflect done state, blanks skipped', () {
    final Note note = base.copyWith(
      title: 'List',
      isChecklist: true,
      checklist: <ChecklistItem>[
        ChecklistItem.create('Milk').copyWith(isDone: true),
        ChecklistItem.create('  '),
        ChecklistItem.create('Eggs'),
      ],
    );
    expect(note.plainText, 'List\n☑ Milk\n☐ Eggs');
  });

  test('tags are appended as hashtags', () {
    expect(
      base.copyWith(content: 'x', tags: <String>['work', 'home']).plainText,
      'x\n\n#work #home',
    );
  });

  test('empty note gives empty text', () {
    expect(base.plainText, isEmpty);
  });
}
