import 'package:flutter/material.dart';
import 'package:sqlite_demo/widgets/app_settings.dart';

import '../helper/db_helper.dart';
import '../model/note.dart';

class ListNotes extends StatefulWidget {
  final List<Note> notes;
  final Function() loadNotes;
  final TextEditingController _titleController;
  final TextEditingController _descriptionController;
  final bool isEditing;
  final Function(Note note) onNoteTap;

  const ListNotes({
    super.key,
    required this.notes,
    required this.loadNotes,
    required TextEditingController titleController,
    required TextEditingController descriptionController,
    required this.isEditing,
    required this.onNoteTap,
  })  : _titleController = titleController,
        _descriptionController = descriptionController,
        super();

  @override
  State<ListNotes> createState() => _ListNotesState();
}

class _ListNotesState extends State<ListNotes> {
  final DBHelper _dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        final person = widget.notes[index];

        return Card(
          margin: AppSettings.all,
          child: ListTile(
            title: Text(
              person.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              person.description,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.normal),
            ),
            // leading: const Icon(Icons.note_alt),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () async {
                await _dbHelper.deleteNote(person.id);
                setState(() {
                  // widget.persons.removeWhere(
                  //     (p) => p.id == person.id);
                  widget.loadNotes();
                });
              },
            ),
            onTap: () async {
              widget._titleController.text = person.title;
              widget._descriptionController.text = person.description;
              await _dbHelper.updateNote(person, person.id);
              widget.onNoteTap(person);
            },
          ),
        );
      },
    );
  }
}
