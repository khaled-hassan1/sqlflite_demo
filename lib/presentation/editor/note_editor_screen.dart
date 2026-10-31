import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../data/models/note.dart';
import '../../data/models/note_color.dart';
import '../../logic/editor_launch_action.dart';
import '../../logic/note_editor_controller.dart';
import 'editor_actions.dart';
import 'widgets/editor_app_bar.dart';
import 'widgets/editor_body.dart';
import 'widgets/editor_bottom_bar.dart';
import '../ios/ios_note_editor_screen.dart';

/// Create / edit a note. The [NoteEditorController] is scoped to this route
/// and disposed automatically when it is popped.
class NoteEditorScreen extends StatelessWidget {
  const NoteEditorScreen({super.key});

  /// Opens the editor for [note], or for a brand-new note when `null`.
  static Future<void> open(
    BuildContext context, {
    Note? note,
    bool checklist = false,
    EditorLaunchAction action = EditorLaunchAction.none,
  }) {
    return Navigator.of(context).push(
      (defaultTargetPlatform == TargetPlatform.iOS
          ? CupertinoPageRoute<void>(
              builder: (_) => ChangeNotifierProvider<NoteEditorController>(
                create: (BuildContext providerContext) => NoteEditorController(
                  note: note ?? Note.create(isChecklist: checklist),
                  isNew: note == null,
                  notes: providerContext.read(),
                  media: providerContext.read(),
                  picker: providerContext.read(),
                  playback: providerContext.read(),
                  launchAction: action,
                ),
                child: const IosNoteEditorScreen(),
              ),
            )
          : MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider<NoteEditorController>(
                create: (BuildContext providerContext) => NoteEditorController(
                  note: note ?? Note.create(isChecklist: checklist),
                  isNew: note == null,
                  notes: providerContext.read(),
                  media: providerContext.read(),
                  picker: providerContext.read(),
                  playback: providerContext.read(),
                  launchAction: action,
                ),
                child: const NoteEditorScreen(),
              ),
            )),
    );
  }

  @override
  Widget build(BuildContext context) {
    _runLaunchAction(context);
    final Brightness brightness = Theme.of(context).brightness;
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) context.read<NoteEditorController>().close();
      },
      // Only the background color depends on the note here.
      child: Selector<NoteEditorController, NoteColor>(
        selector: (_, NoteEditorController c) => c.note.color,
        builder: (BuildContext context, NoteColor color, Widget? body) =>
            Scaffold(
              backgroundColor: color == NoteColor.none
                  ? null
                  : color.container(brightness),
              appBar: const EditorAppBar(),
              body: body,
            ),
        // Toolbar lives in the body so it rides above the keyboard.
        child: const SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Expanded(child: EditorBody()),
              EditorBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  /// Runs the quick-capture action once, after the first frame, using this
  /// screen's context (which sits *below* the editor provider).
  void _runLaunchAction(BuildContext context) {
    final EditorLaunchAction action = context
        .read<NoteEditorController>()
        .takeLaunchAction();
    if (action == EditorLaunchAction.none) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) EditorActions.run(context, action);
    });
  }
}
