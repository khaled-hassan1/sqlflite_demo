import 'package:flutter/material.dart';

import '../helper/db_helper.dart';
import '../model/person.dart';

class ListNotes extends StatefulWidget {
  final List<Person> persons;
  final Function() loadPersons;
  final TextEditingController _titleController;
  final TextEditingController _descriptionController;
  const ListNotes({
    super.key,
    required this.persons,
    required this.loadPersons,
    required TextEditingController titleController,
    required TextEditingController descriptionController,
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
            leading: const Icon(Icons.person),
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
              Person updatePerson = Person(
                  id: person.id,
                  title: widget._titleController.text,
                  description: widget._descriptionController.text);
              person.description = widget._descriptionController.text;
              await _dbHelper.updatePerson(updatePerson, person.id);
              int personIndex = widget.persons
                  .indexWhere((element) => element.id == person.id);
              if (personIndex != -1) {
                setState(() {
                  widget.persons[personIndex] =updatePerson;
                });
              }
            },
          ),
        );
      },
    );
  }
}
 