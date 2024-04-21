import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../helper/db_helper.dart';
import '../model/person.dart';
import '../widgets/center_text_widget.dart';
import '../widgets/list_notes.dart';
import '../widgets/text_field_container.dart';

class HomePageScreen extends StatefulWidget {
  final Locale locale;
  final Function(Locale locale) onLocaleChanged;

  const HomePageScreen(
      {super.key, required this.locale, required this.onLocaleChanged});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<Person> _persons = [];
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  bool _isEditing = false;
  late Person _editingPerson;
  Locale currentLocale = const Locale('en');
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    _loadPersons();
    currentLocale = widget.locale;
    myFocusNode = FocusNode();
  }

  Future<void> _loadPersons() async {
    List<Person> fetchedPersons = await _dbHelper.getAllPersons();
    setState(() {
      _persons = fetchedPersons;
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
          _persons.add(newPerson);
          _controllerTitle.clear();
          _controllerDescription.clear();
        });
      }
    }
  }

  int _getCount() {
    return _persons.length;
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
  void dispose() {
    _controllerDescription.dispose();
    _controllerTitle.dispose();
    _dbHelper.close();
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    S local = S.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(local.title),
        // const Text("Notes"),
        leading: IconButton(
          icon: const Icon(
            Icons.translate,
          ),
          onPressed: () {
            Locale newLocale = currentLocale.languageCode == 'en'
                ? const Locale('ar')
                : const Locale('en');
            setState(() {
              currentLocale = newLocale;
            });
            widget.onLocaleChanged(newLocale);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                color: const Color.fromARGB(255, 236, 191, 176),
                // color: Theme.of(context).colorScheme.primary.withAlpha(10),
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                child: _getCount() == 0
                    ? const CenterTextWidget()
                    : ListNotes(
                        persons: _persons,
                        loadPersons: _loadPersons,
                        titleController: _controllerTitle,
                        descriptionController: _controllerDescription,
                        isEditing: _isEditing,
                        onNoteTap: (Person person) {
                          myFocusNode.requestFocus();
                          setState(() {
                            _isEditing = true;
                            _editingPerson = person;
                            _controllerTitle.text = person.title;
                            _controllerDescription.text = person.description;
                          });
                        },
                      )),
            const Divider(
              endIndent: 100,
              indent: 100,
            ),
            TextFieldContainer(
              myFocusNode: myFocusNode,
              local: local,
              onTapOutside: (_) => unFocus(context),
              controllerTitle: _controllerTitle,
              controllerDescription: _controllerDescription,
              isEditing: _isEditing,
              onPressedEdit: _editPerson,
              onPressedAdd: _addPerson,
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: local.countNotes,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextSpan(
                  text: _getCount().toString(),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.deepOrange),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void unFocus(BuildContext context) {
    _controllerTitle.clear();
    _controllerDescription.clear();
    FocusScope.of(context).unfocus();
  }
}
