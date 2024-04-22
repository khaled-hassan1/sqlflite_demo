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
  final bool isDark;
  final VoidCallback onThemeModeChanged;
  final Function(Locale locale, String langCode) onLocaleChanged;

  const HomePageScreen(
      {super.key,
      required this.locale,
      required this.onLocaleChanged,
      required this.onThemeModeChanged,
      required this.isDark});

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
      String id = DateTime.now().toString();
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
      floatingActionButton: buildFloatingActionButton(context, local),
      appBar: buildAppBar(local),
      body: buildContainerBody(context, local),
      persistentFooterButtons: persistentFooterButtons(local, context),
    );
  }

  FloatingActionButton buildFloatingActionButton(
      BuildContext context, S local) {
    return FloatingActionButton(
      splashColor: AppSettings.deepOrange,
      onPressed: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: TextFieldContainer(
                myFocusNode: myFocusNode,
                local: local,
                onTapOutside: (_) => unFocus(context),
                controllerTitle: _controllerTitle,
                controllerDescription: _controllerDescription,
                isEditing: _isEditing,
                onPressedEdit: () {
                  _editNotes();
                  Navigator.of(context).pop();
                },
                onPressedAdd: () {
                  _addNotes();
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }

  List<Widget> persistentFooterButtons(S local, BuildContext context) {
    return [
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
    ];
  }

  Container buildContainerBody(BuildContext context, S local) {
    return Container(
        color: widget.isDark
            ? const Color.fromARGB(255, 236, 191, 176)
            : Colors.grey.shade600,
        // color: Theme.of(context).colorScheme.primary.withAlpha(10),
        // height: MediaQuery.of(context).size.height / 2,
        width: double.infinity,
        child: _getCount() == 0
            ? const CenterTextWidget()
            : ListNotes(
                notes: _notes,
                loadNotes: _loadNotes,
                titleController: _controllerTitle,
                descriptionController: _controllerDescription,
                isEditing: _isEditing,
                onNoteTap: (Note notes) async {
                  setState(() {
                    _isEditing = true;
                    _editingnotes = notes;
                    _controllerTitle.text = notes.title;
                    _controllerDescription.text = notes.description;
                  });
                  myFocusNode.requestFocus();
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: TextFieldContainer(
                          myFocusNode: myFocusNode,
                          local: local,
                          onTapOutside: (_) => unFocus(context),
                          controllerTitle: _controllerTitle,
                          controllerDescription: _controllerDescription,
                          isEditing: _isEditing,
                          onPressedEdit: () {
                            _editNotes();
                            Navigator.of(context).pop();
                          },
                          onPressedAdd: () {
                            // _addNotes();
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  );
                }));
  }

  AppBar buildAppBar(S local) {
    return AppBar(
      actions: [
        IconButton(
            onPressed: widget.onThemeModeChanged,
            icon: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode))
      ],
      centerTitle: true,
      title: Text(local.title),
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
    );
  }

  void unFocus(BuildContext context) {
    _controllerTitle.clear();
    _controllerDescription.clear();
    FocusScope.of(context).unfocus();
  }
}
