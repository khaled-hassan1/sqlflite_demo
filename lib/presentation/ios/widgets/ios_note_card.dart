import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/note.dart';
import '../../../logic/notes_provider.dart';
import '../../editor/note_editor_screen.dart';

class IosNoteCard extends StatelessWidget {
  const IosNoteCard({super.key, required this.note});
  final Note note;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = CupertinoTheme.brightnessOf(context);
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: GestureDetector(
          onTap: () => NoteEditorScreen.open(context, note: note),
          onLongPress: () => _showActions(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: note.color.container(brightness),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CupertinoColors.separator.resolveFrom(context),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (note.title.isNotEmpty)
                  Text(
                    note.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: note.color.onContainer(brightness),
                    ),
                  ),
                if (note.content.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 5),
                  Text(
                    note.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: note.color.onContainer(brightness)),
                  ),
                ],
                if (note.isChecklist) ...<Widget>[
                  const SizedBox(height: 6),
                  for (final item in note.checklist.take(3))
                    Text(
                      '${item.isDone ? '✓' : '○'}  ${item.text}',
                      maxLines: 1,
                      style: TextStyle(
                        color: note.color.onContainer(brightness),
                      ),
                    ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Text(
                      Formatters.relativeDate(note.updatedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: note.color
                            .onContainer(brightness)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    if (note.attachments.isNotEmpty) ...<Widget>[
                      const SizedBox(width: 8),
                      const Icon(CupertinoIcons.paperclip, size: 15),
                    ],
                    if (note.isPinned) ...<Widget>[
                      const Spacer(),
                      const Icon(CupertinoIcons.pin_fill, size: 15),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    final NotesProvider notes = context.read<NotesProvider>();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext popupContext) => CupertinoActionSheet(
        title: Text(note.title.isEmpty ? AppStrings.newNote : note.title),
        actions: <Widget>[
          if (!note.isTrashed)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(popupContext);
                notes.togglePin(note);
              },
              child: Text(note.isPinned ? AppStrings.unpin : AppStrings.pin),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(popupContext);
              notes.setStatus(
                note,
                note.isTrashed || note.isArchived
                    ? NoteStatus.active
                    : NoteStatus.archived,
              );
            },
            child: Text(
              note.isTrashed
                  ? AppStrings.restoreNote
                  : note.isArchived
                  ? AppStrings.unarchive
                  : AppStrings.archiveAction,
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(popupContext);
              if (note.isTrashed) {
                _confirmDelete(context, notes);
              } else {
                notes.setStatus(note, NoteStatus.trashed);
              }
            },
            child: Text(
              note.isTrashed
                  ? AppStrings.deleteForever
                  : AppStrings.moveToTrash,
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(popupContext),
          child: const Text(AppStrings.cancel),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NotesProvider notes) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => CupertinoAlertDialog(
        title: const Text(AppStrings.deleteForever),
        content: const Text(AppStrings.deleteForeverConfirm),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              notes.deleteForever(note);
            },
            child: const Text(AppStrings.deleteForever),
          ),
        ],
      ),
    );
  }
}
