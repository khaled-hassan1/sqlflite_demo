import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../data/models/note_query.dart';
import '../../../logic/notes_provider.dart';
import '../../../logic/editor_launch_action.dart';
import '../../editor/note_editor_screen.dart';

/// Quick-capture bar: new checklist, drawing, voice, image + the "new note"
/// FAB on the start (right in RTL) edge. Hidden outside the main notes page.
class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<NotesProvider, bool>(
      selector: (_, NotesProvider p) => p.query.section == NoteSection.notes,
      builder: (BuildContext context, bool visible, Widget? bar) =>
          AnimatedSwitcher(
            duration: AppDurations.medium,
            child: visible ? bar : const SizedBox.shrink(),
          ),
      child: const BottomAppBar(child: _BarContent()),
    );
  }
}

class _BarContent extends StatelessWidget {
  const _BarContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        FloatingActionButton(
          heroTag: null,
          elevation: 0,
          tooltip: AppStrings.newNote,
          onPressed: () => NoteEditorScreen.open(context),
          child: const Icon(Icons.add_rounded, size: AppSizes.iconLg),
        ),
        const Spacer(),
        IconButton(
          tooltip: AppStrings.newImage,
          icon: const Icon(Icons.image_outlined),
          onPressed: () =>
              NoteEditorScreen.open(context, action: EditorLaunchAction.image),
        ),
        IconButton(
          tooltip: AppStrings.newVoice,
          icon: const Icon(Icons.mic_none_rounded),
          onPressed: () =>
              NoteEditorScreen.open(context, action: EditorLaunchAction.audio),
        ),
        IconButton(
          tooltip: AppStrings.newDrawing,
          icon: const Icon(Icons.brush_outlined),
          onPressed: () => NoteEditorScreen.open(
            context,
            action: EditorLaunchAction.drawing,
          ),
        ),
        IconButton(
          tooltip: AppStrings.newChecklist,
          icon: const Icon(Icons.check_box_outlined),
          onPressed: () => NoteEditorScreen.open(context, checklist: true),
        ),
      ],
    );
  }
}
