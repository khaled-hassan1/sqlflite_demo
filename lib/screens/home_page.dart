import 'package:flutter/material.dart';

import '../widgets/app_settings.dart';
import '../generated/l10n.dart';
import '../helper/db_helper.dart';
import '../model/note.dart';
import '../widgets/center_text_widget.dart';
import '../widgets/list_notes.dart';
import '../widgets/text_field_container.dart';

class HomePageScreen extends StatefulWidget {
  final Locale locale;
  final Function(Locale locale, String langCode) onLocaleChanged;

  const HomePageScreen(
      {super.key, required this.locale, required this.onLocaleChanged});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<Note> _notes = [];
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  bool _isEditing = false;
  late Note _editingnotes;
  Locale currentLocale = const Locale('en');
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    currentLocale = widget.locale;
    myFocusNode = FocusNode();
  }

  Future<void> _loadNotes() async {
    List<Note> fetchedNotes = await _dbHelper.getAllNotes();
    setState(() {
      _notes = fetchedNotes;
    });
  }

  Future<void> _addNotes() async {
    String title = _controllerTitle.text.trim();
    String description = _controllerDescription.text.trim();
    if (title.isNotEmpty || description.isNotEmpty) {
      var id = DateTime.now().toString();
      Note newNote = Note(id: id, title: title, description: description);
      int result = await _dbHelper.insertNewNote(newNote);
      if (result >= 0) {
        setState(() {
          _notes.add(newNote);
          _controllerTitle.clear();
          _controllerDescription.clear();
        });
      }
    }
  }

  int _getCount() {
    return _notes.length;
  }

  Future<void> _editNotes() async {
    String title = _controllerTitle.text.trim();
    String description = _controllerDescription.text.trim();
    if (title.isNotEmpty || description.isNotEmpty) {
      // Update the person object with the new data
      _editingnotes.title = title;
      _editingnotes.description = description;
      // Update the person in the database
      await _dbHelper.updateNote(_editingnotes, _editingnotes.id);
      // Update the UI
      setState(() {
        _isEditing = false; // Exit editing mode
        _editingnotes =
            Note(id: '', title: '', description: ''); // Reset editing person
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
            widget.onLocaleChanged(newLocale, newLocale.languageCode);
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
                        notes: _notes,
                        loadNotes: _loadNotes,
                        titleController: _controllerTitle,
                        descriptionController: _controllerDescription,
                        isEditing: _isEditing,
                        onNoteTap: (Note notes) {
                          myFocusNode.requestFocus();
                          setState(() {
                            _isEditing = true;
                            _editingnotes = notes;
                            _controllerTitle.text = notes.title;
                            _controllerDescription.text = notes.description;
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
              onPressedEdit: _editNotes,
              onPressedAdd: _addNotes,
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
                      .copyWith(color: AppSettings.deepOrange),
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
