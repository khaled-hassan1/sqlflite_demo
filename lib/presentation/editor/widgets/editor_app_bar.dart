import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../data/models/note.dart';
import '../../../logic/note_editor_controller.dart';
import '../../../logic/notes_provider.dart';

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EditorAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.transparent,
      actions: const <Widget>[_PinButton(), _ArchiveButton(), _MoreMenu()],
    );
  }
}

class _PinButton extends StatelessWidget {
  const _PinButton();

  @override
  Widget build(BuildContext context) {
    return Selector<NoteEditorController, bool>(
      selector: (_, NoteEditorController c) => c.note.isPinned,
      builder: (BuildContext context, bool pinned, _) => IconButton(
        tooltip: pinned ? AppStrings.unpin : AppStrings.pin,
        isSelected: pinned,
        icon: const Icon(Icons.push_pin_outlined),
        selectedIcon: const Icon(Icons.push_pin),
        onPressed: context.read<NoteEditorController>().togglePin,
      ),
    );
  }
}

class _ArchiveButton extends StatelessWidget {
  const _ArchiveButton();

  @override
  Widget build(BuildContext context) {
    return Selector<NoteEditorController, bool>(
      selector: (_, NoteEditorController c) => c.note.isArchived,
      builder: (BuildContext context, bool archived, _) => IconButton(
        tooltip: archived ? AppStrings.unarchive : AppStrings.archiveAction,
        icon: Icon(
          archived ? Icons.unarchive_outlined : Icons.archive_outlined,
        ),
        onPressed: () async {
          final NavigatorState navigator = Navigator.of(context);
          await context.read<NoteEditorController>().toggleArchive();
          navigator.pop();
        },
      ),
    );
  }
}

enum _MenuAction {
  share(Icons.share_outlined, AppStrings.shareNote),
  copy(Icons.copy_rounded, AppStrings.copyText),
  trash(Icons.delete_outline_rounded, AppStrings.moveToTrash);

  const _MenuAction(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      tooltip: AppStrings.more,
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (_MenuAction action) async {
        final NavigatorState navigator = Navigator.of(context);
        final NoteEditorController editor = context
            .read<NoteEditorController>();
        final NotesProvider notes = context.read<NotesProvider>();
        switch (action) {
          case _MenuAction.share:
            await notes.share(<Note>[editor.note]);
          case _MenuAction.copy:
            await notes.copyText(<Note>[editor.note]);
          case _MenuAction.trash:
            await editor.moveToTrash();
            navigator.pop();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_MenuAction>>[
        for (final _MenuAction action in _MenuAction.values)
          PopupMenuItem<_MenuAction>(
            value: action,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(action.icon),
              title: Text(action.label),
            ),
          ),
      ],
    );
  }
}
