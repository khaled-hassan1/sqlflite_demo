import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/models/note_query.dart';
import '../../../logic/notes_provider.dart';
import '../../widgets/confirm_dialog.dart';

/// Area under the search bar: category chips on the main notes page, or a
/// titled header for archive / trash / label pages.
class HomeContextBar extends StatelessWidget {
  const HomeContextBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<NotesProvider, ({NoteSection section, String? tag})>(
      selector: (_, NotesProvider p) =>
          (section: p.query.section, tag: p.query.tag),
      builder:
          (
            BuildContext context,
            ({NoteSection section, String? tag}) state,
            _,
          ) {
            if (state.tag != null) {
              return _PageHeader(
                icon: Icons.label_outline_rounded,
                title: '${AppStrings.tagPrefix}${state.tag}',
              );
            }
            return switch (state.section) {
              NoteSection.notes => const _CategoryChips(),
              NoteSection.archive => const _PageHeader(
                icon: Icons.archive_outlined,
                title: AppStrings.archive,
              ),
              NoteSection.trash => const _PageHeader(
                icon: Icons.delete_outline_rounded,
                title: AppStrings.trash,
                subtitle: AppStrings.trashHint,
                trailing: _EmptyTrashButton(),
              ),
            };
          },
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  static const List<({NoteCategory category, String label, IconData icon})>
  _items = <({NoteCategory category, String label, IconData icon})>[
    (
      category: NoteCategory.all,
      label: AppStrings.filterAll,
      icon: Icons.dashboard_outlined,
    ),
    (
      category: NoteCategory.audio,
      label: AppStrings.filterAudio,
      icon: Icons.mic_none_rounded,
    ),
    (
      category: NoteCategory.checklists,
      label: AppStrings.filterChecklists,
      icon: Icons.check_box_outlined,
    ),
    (
      category: NoteCategory.attachments,
      label: AppStrings.filterAttachments,
      icon: Icons.image_outlined,
    ),
    (
      category: NoteCategory.drawings,
      label: AppStrings.filterDrawings,
      icon: Icons.brush_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.filterChipsHeight + AppSpacing.md,
      child: Selector<NotesProvider, NoteCategory>(
        selector: (_, NotesProvider p) => p.query.category,
        builder: (BuildContext context, NoteCategory selected, _) =>
            ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.margin,
                vertical: AppSpacing.xs,
              ),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final ({NoteCategory category, String label, IconData icon})
                item = _items[index];
                final bool isSelected = item.category == selected;
                return ChoiceChip(
                  selected: isSelected,
                  avatar: Icon(
                    item.icon,
                    color: isSelected ? context.palette.onAccent : null,
                  ),
                  label: Text(item.label),
                  labelStyle: context.texts.labelLarge?.copyWith(
                    color: isSelected
                        ? context.palette.onAccent
                        : context.colors.onSurfaceVariant,
                  ),
                  onSelected: (_) =>
                      context.read<NotesProvider>().setCategory(item.category),
                );
              },
            ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.margin,
        AppSpacing.sm,
        AppSpacing.sm,
        0,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: context.colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: context.texts.titleLarge),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.outline,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
          IconButton(
            tooltip: AppStrings.back,
            icon: const Icon(Icons.close_rounded),
            onPressed: () =>
                context.read<NotesProvider>().setQuery(const NoteQuery()),
          ),
        ],
      ),
    );
  }
}

class _EmptyTrashButton extends StatelessWidget {
  const _EmptyTrashButton();

  @override
  Widget build(BuildContext context) {
    return Selector<NotesProvider, bool>(
      selector: (_, NotesProvider p) => p.counts.trash > 0,
      builder: (BuildContext context, bool hasItems, _) => TextButton(
        style: TextButton.styleFrom(foregroundColor: context.colors.error),
        onPressed: hasItems ? () => _confirm(context) : null,
        child: const Text(AppStrings.emptyTrashAction),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final NotesProvider notes = context.read<NotesProvider>();
    final bool ok = await showConfirmDialog(
      context,
      title: AppStrings.emptyTrashAction,
      message: AppStrings.emptyTrashConfirm,
      confirmLabel: AppStrings.deleteForever,
    );
    if (ok) await notes.emptyTrash();
  }
}
