import 'package:flutter/material.dart';
import '../helper/db_helper.dart';
import '../model/person.dart';
import '../widgets/list_notes.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<Person> persons = [];
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  bool _isEditing = false;
  late Person _editingPerson;

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
      Person newPerson = Person(id: id, title: title, description: description);
      int result = await _dbHelper.insertNewPerson(newPerson);
      if (result >= 0) {
        setState(() {
          persons.add(newPerson);
          _controllerTitle.clear();
          _controllerDescription.clear();
        });
      }
    }
  }

  int getCount() {
    return persons.length;
  }

  Future<void> _editPerson() async {
    String title = _controllerTitle.text.trim();
    String description = _controllerDescription.text.trim();
    if (title.isNotEmpty || description.isNotEmpty) {
      // Update the person object with the new data
      _editingPerson.title = title;
      _editingPerson.description = description;
      // Update the person in the database
      await _dbHelper.updatePerson(_editingPerson, _editingPerson.id);
      // Update the UI
      setState(() {
        _isEditing = false; // Exit editing mode
        _editingPerson =
            Person(id: '', title: '', description: ''); // Reset editing person
        _controllerTitle.clear();
        _controllerDescription.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Notes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.brown.shade400,
                height: 400,
                width: double.infinity,
                child: ListNotes(
                  persons: persons,
                  loadPersons: _loadPersons,
                  titleController: _controllerTitle,
                  descriptionController: _controllerDescription,
                  isEditing: _isEditing,
                  onNoteTap: (Person person) {
                    setState(() {
                      _isEditing = true;
                      _editingPerson = person;
                      _controllerTitle.text = person.title;
                      _controllerDescription.text = person.description;
                    });
                  },
                ),
              ),
              const Divider(),
              Container(
                color: Colors.blueGrey.shade100,
                height: 300,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          onTapOutside: (_) => unFocus(context),
                          controller: _controllerTitle,
                          decoration: const InputDecoration(
                            hintText: "Title...",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                         const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          onTapOutside: (_) => unFocus(context),
                          controller: _controllerDescription,
                          decoration: const InputDecoration(
                            hintText: 'Description...',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: _isEditing ? _editPerson : _addPerson,
                          child: Text(_isEditing ? 'Update' : 'Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
