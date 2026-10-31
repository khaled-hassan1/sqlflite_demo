import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/models/note.dart';
import '../../../data/models/note_color.dart';
import '../../../logic/notes_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/note_color_picker.dart';
import '../../widgets/app_bottom_sheet.dart';

/// Long-press menu of a note card. Reads the live note by id so color
/// changes reflect immediately.
class NoteActionsSheet extends StatelessWidget {
  const NoteActionsSheet({super.key, required this.noteId});

  final String noteId;

  static Future<void> show(BuildContext context, String noteId) {
    return showAppBottomSheet<void>(
      context: context,
      builder: (_) => NoteActionsSheet(noteId: noteId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<NotesProvider, Note?>(
      selector: (_, NotesProvider p) => p.byId(noteId),
      builder: (BuildContext context, Note? note, _) {
        if (note == null) return const SizedBox.shrink();
        final NotesProvider notes = context.read<NotesProvider>();
        void close() => Navigator.pop(context);

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (note.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: Text(
                    note.title,
                    style: context.texts.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (!note.isTrashed) ...<Widget>[
                NoteColorPicker(
                  selected: note.color,
                  onSelected: (NoteColor color) => notes.setColor(note, color),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              ..._actions(context, note, notes, close),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _actions(
    BuildContext context,
    Note note,
    NotesProvider notes,
    VoidCallback close,
  ) {
    Widget tile(
      IconData icon,
      String label,
      VoidCallback onTap, {
      bool danger = false,
      bool closeFirst = true,
    }) {
      final Color? color = danger ? context.colors.error : null;
      return ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color)),
        onTap: () {
          if (closeFirst) close();
          onTap();
        },
      );
    }

    if (note.isTrashed) {
      return <Widget>[
        tile(
          Icons.restore_from_trash_outlined,
          AppStrings.restoreNote,
          () => notes.setStatus(note, NoteStatus.active),
        ),
        tile(
          Icons.delete_forever_outlined,
          AppStrings.deleteForever,
          () async {
            final bool ok = await showConfirmDialog(
              context,
              title: AppStrings.deleteForever,
              message: AppStrings.deleteForeverConfirm,
              confirmLabel: AppStrings.deleteForever,
            );
            if (context.mounted) close();
            if (ok) await notes.deleteForever(note);
          },
          danger: true,
          closeFirst: false,
        ),
      ];
    }
    return <Widget>[
      if (note.isActive)
        tile(
          note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          note.isPinned ? AppStrings.unpin : AppStrings.pin,
          () => notes.togglePin(note),
        ),
      tile(
        note.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
        note.isArchived ? AppStrings.unarchive : AppStrings.archiveAction,
        () => notes.setStatus(
          note,
          note.isArchived ? NoteStatus.active : NoteStatus.archived,
        ),
      ),
      tile(
        Icons.delete_outline_rounded,
        AppStrings.moveToTrash,
        () => notes.setStatus(note, NoteStatus.trashed),
        danger: true,
      ),
    ];
  }
}
