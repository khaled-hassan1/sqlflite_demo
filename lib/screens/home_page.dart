import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../helper/db_helper.dart';
import '../model/person.dart';
import '../widgets/list_notes.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<Person> persons = [];
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    List<Person> fetchedPersons = await _dbHelper.getAllPersons();
    setState(() {
      persons = fetchedPersons;
    });
  }

  Future<void> _addPerson() async {
    String title = _controllerTitle.text.trim();
    String description = _controllerDescription.text.trim();
    if (title.isNotEmpty || description.isNotEmpty) {
      var id = DateTime.now().toString();
      Person person = Person(id: id, title: title, description: description);
      int result = await _dbHelper.insertNewPerson(person);
      if (result >= 0) {
        setState(() {
          persons.add(person);
          _controllerTitle.clear();
          _controllerDescription.clear();
        });
      }
    }
  }

  int getCount() {
    return persons.length;
  }
  Future<void> _editPerson(Person person) async {
  String title = _controllerTitle.text.trim();
  String description = _controllerDescription.text.trim();
  if (title.isNotEmpty || description.isNotEmpty) {
    // Update the person object with the new data
    person.title = title;
    person.description = description;
    // Update the person in the database
    await _dbHelper.updatePerson(person, person.id);
    // Update the UI
    setState(() {
      // No need to add a new person, just update the existing one
      _controllerTitle.clear();
      _controllerDescription.clear();
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.grey.shade400,
              height: 300,
              width: double.infinity,
              child: ListNotes(
                persons: persons,
                loadPersons: _loadPersons,
                titleController: _controllerTitle,
                descriptionController: _controllerDescription,
              ),
            ),
            const Divider(),
            Container(
              color: Colors.grey.shade400,
              height: 200,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      onTapOutside: (_) => unFocus(context),
                      controller: _controllerTitle,
                      decoration: const InputDecoration(
                        hintText: "Title...",
                      ),
                    ),
                    TextField(
                      onTapOutside: (_) => unFocus(context),
                      controller: _controllerDescription,
                      decoration: const InputDecoration(
                        hintText: 'Description...',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _addPerson,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        Center(
          child: Text('Notes: ${getCount().toString()}'),
        )
      ],
    );
  }

  void unFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
