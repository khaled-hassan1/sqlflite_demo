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

  _loadPersons() async {
    List<Person> fetchedPersons = await _dbHelper.getAllPersons();
    setState(() {
      persons = fetchedPersons;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: ListNotes(
              persons: persons,
            ),
          ),
          const Divider(),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Column(
              children: [
                TextField(
                  controller: _controllerTitle,
                  decoration: InputDecoration(
                    hintText: Person.getNewEmpty().title,
                  ),
                ),
                TextField(
                  controller: _controllerDescription,
                  decoration: InputDecoration(
                    hintText: Person.getNewEmpty().description,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
