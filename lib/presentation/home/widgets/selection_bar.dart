import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/note.dart';
import '../../../data/models/note_color.dart';
import '../../../data/models/note_query.dart';
import '../../../logic/notes_provider.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/note_color_picker.dart';

/// Replaces the search bar while notes are selected: count + bulk actions.
class SelectionBar extends StatelessWidget {
  const SelectionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NotesProvider notes = context.read<NotesProvider>();
    final AppPalette palette = context.palette;
    return Padding(
      padding: AppInsets.screen,
      child: Material(
        color: palette.accent,
        borderRadius: AppRadius.searchAll,
        child: SizedBox(
          height: AppSizes.searchBarHeight,
          child: IconButtonTheme(
            // Compact buttons so five actions + the count fit on 360dp phones.
            data: IconButtonThemeData(
              style: IconButton.styleFrom(
                foregroundColor: palette.onAccent,
                visualDensity: VisualDensity.compact,
              ),
            ),
            child: Selector<NotesProvider, (int, NoteSection)>(
              selector: (_, NotesProvider p) =>
                  (p.selectedIds.length, p.query.section),
              builder: (BuildContext context, (int, NoteSection) state, _) {
                final (int count, NoteSection section) = state;
                return Row(
                  children: <Widget>[
                    const SizedBox(width: AppSpacing.xs),
                    IconButton(
                      tooltip: AppStrings.clearSelection,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: notes.clearSelection,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: AppDurations.fast,
                        transitionBuilder: (
                          Widget child,
                          Animation<double> a,
                        ) => ScaleTransition(scale: a, child: child),
                        child: Text(
                          '${Formatters.number(count)} ${AppStrings.selectedSuffix}',
                          key: ValueKey<int>(count),
                          style: context.texts.titleMedium?.copyWith(
                            color: palette.onAccent,
                          ),
                        ),
                      ),
                    ),
                    ..._actions(context, notes, section),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(
    BuildContext context,
    NotesProvider notes,
    NoteSection section,
  ) {
    final Widget selectAll = IconButton(
      tooltip: AppStrings.selectAll,
      icon: const Icon(Icons.select_all_rounded),
      onPressed: notes.selectAllVisible,
    );
    if (section == NoteSection.trash) {
      return <Widget>[
        selectAll,
        IconButton(
          tooltip: AppStrings.restoreNote,
          icon: const Icon(Icons.restore_from_trash_outlined),
          onPressed: () => notes.setStatusSelected(NoteStatus.active),
        ),
        IconButton(
          tooltip: AppStrings.deleteForever,
          icon: const Icon(Icons.delete_forever_outlined),
          onPressed: () => _confirmDeleteForever(context, notes),
        ),
      ];
    }
    final bool isArchive = section == NoteSection.archive;
    return <Widget>[
      selectAll,
      if (!isArchive)
        IconButton(
          tooltip: AppStrings.pin,
          icon: const Icon(Icons.push_pin_outlined),
          onPressed: notes.togglePinSelected,
        ),
      IconButton(
        tooltip: AppStrings.changeColor,
        icon: const Icon(Icons.palette_outlined),
        onPressed: () => _pickColor(context, notes),
      ),
      IconButton(
        tooltip: AppStrings.moveToTrash,
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: () => notes.setStatusSelected(NoteStatus.trashed),
      ),
      _MoreActions(isArchive: isArchive),
    ];
  }

  Future<void> _pickColor(BuildContext context, NotesProvider notes) {
    return showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: NoteColorPicker(
          selected: NoteColor.none,
          onSelected: (NoteColor color) {
            Navigator.pop(sheetContext);
            notes.setColorSelected(color);
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteForever(
    BuildContext context,
    NotesProvider notes,
  ) async {
    final bool ok = await showConfirmDialog(
      context,
      title: AppStrings.deleteForever,
      message: AppStrings.deleteSelectedConfirm,
      confirmLabel: AppStrings.deleteForever,
    );
    if (ok) await notes.deleteSelectedForever();
  }
}

enum _MoreAction {
  archive(Icons.archive_outlined, AppStrings.archiveAction),
  unarchive(Icons.unarchive_outlined, AppStrings.unarchive),
  share(Icons.share_outlined, AppStrings.shareNote),
  copy(Icons.copy_rounded, AppStrings.copyText),
  duplicate(Icons.library_add_outlined, AppStrings.duplicateNote);

  const _MoreAction(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Overflow menu: (un)archive, share, copy text and duplicate the selection.
class _MoreActions extends StatelessWidget {
  const _MoreActions({required this.isArchive});

  final bool isArchive;

  Iterable<_MoreAction> get _visible => _MoreAction.values.where(
    (_MoreAction a) => switch (a) {
      _MoreAction.archive => !isArchive,
      _MoreAction.unarchive => isArchive,
      _ => true,
    },
  );

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MoreAction>(
      tooltip: AppStrings.more,
      icon: Icon(Icons.more_vert_rounded, color: context.palette.onAccent),
      onSelected: (_MoreAction action) {
        final NotesProvider notes = context.read<NotesProvider>();
        switch (action) {
          case _MoreAction.archive:
            notes.setStatusSelected(NoteStatus.archived);
          case _MoreAction.unarchive:
            notes.setStatusSelected(NoteStatus.active);
          case _MoreAction.share:
            notes.shareSelected();
          case _MoreAction.copy:
            notes.copySelected();
          case _MoreAction.duplicate:
            notes.duplicateSelected();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_MoreAction>>[
        for (final _MoreAction action in _visible)
          PopupMenuItem<_MoreAction>(
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
