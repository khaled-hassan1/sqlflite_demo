import 'package:flutter/material.dart';

import '../helper/db_helper.dart';
import '../model/person.dart';

class ListNotes extends StatefulWidget {
  final List<Person> persons;
  final Function() loadPersons;
  final TextEditingController _titleController;
  final TextEditingController _descriptionController;
  final bool isEditing;
  final Function(Person person) onNoteTap;
  const ListNotes({
    super.key,
    required this.persons,
    required this.loadPersons,
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
      itemCount: widget.persons.length,
      itemBuilder: (context, index) {
        final person = widget.persons[index];
        return Card(
          child: ListTile(
            title: Text(person.title),
            subtitle: Text(person.description),
            leading: const Icon(Icons.note_alt),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () async {
                await _dbHelper.deletePerson(person.id);
                setState(() {
                  // widget.persons.removeWhere(
                  //     (p) => p.id == person.id);
                  widget.loadPersons();
                });
              },
            ),
            onTap: () async {
              widget._titleController.text = person.title;
              widget._descriptionController.text = person.description;
              await _dbHelper.updatePerson(person, person.id);
              widget.onNoteTap(person);
            },
          ),
        );
      },
    );
  }
}
