import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/note.dart';
import '../../../data/models/note_query.dart';
import '../../../data/models/notes_overview.dart';
import '../../../logic/notes_provider.dart';
import '../../../logic/settings_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import 'note_grid_item.dart';
import '../../widgets/appear_animation.dart';

/// Pinned + other notes as masonry (or single-column) slivers.
///
/// Rebuilds only when the cached [NotesView] instance or the layout mode
/// changes — typing in the editor or toggling the theme does not touch it.
class NotesSlivers extends StatelessWidget {
  const NotesSlivers({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return Selector2<SettingsProvider, NotesProvider, (bool, NotesView)>(
      selector: (_, SettingsProvider s, NotesProvider p) =>
          (s.isGridView, p.view),
      builder: (BuildContext context, (bool, NotesView) state, _) {
        final (bool isGrid, NotesView view) = state;
        final int columns = AppBreakpoints.columnsFor(width, isGrid: isGrid);
        if (view.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: AppearAnimation(child: _Empty()),
          );
        }
        return SliverMainAxisGroup(
          slivers: <Widget>[
            if (view.pinned.isNotEmpty) ...<Widget>[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: AppStrings.pinned,
                  icon: Icons.push_pin_outlined,
                  trailing: MutedLabel(
                    '${Formatters.number(view.pinned.length)} ${AppStrings.notesCountSuffix}',
                  ),
                ),
              ),
              _NotesGrid(notes: view.pinned, columns: columns),
              if (view.others.isNotEmpty)
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: AppStrings.others,
                    trailing: MutedLabel(
                      '${Formatters.number(view.others.length)} ${AppStrings.notesCountSuffix}',
                    ),
                  ),
                ),
            ] else
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            _NotesGrid(notes: view.others, columns: columns),
          ],
        );
      },
    );
  }
}

class _NotesGrid extends StatelessWidget {
  const _NotesGrid({required this.notes, required this.columns});

  final List<Note> notes;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: AppInsets.screen,
      sliver: SliverMasonryGrid.count(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.gutter,
        crossAxisSpacing: AppSpacing.gutter,
        childCount: notes.length,
        itemBuilder: (BuildContext context, int index) {
          final Note note = notes[index];
          return NoteGridItem(
            key: ValueKey<String>(note.id),
            note: note,
            canReorder: !note.isTrashed,
          );
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Selector<NotesProvider, (NoteSection, bool)>(
      selector: (_, NotesProvider p) =>
          (p.query.section, p.isSearching || !p.query.isDefault),
      builder: (BuildContext context, (NoteSection, bool) state, _) {
        final (NoteSection section, bool isFiltered) = state;
        return switch (section) {
          NoteSection.archive => const EmptyState(
            icon: Icons.archive_outlined,
            message: AppStrings.emptyArchive,
          ),
          NoteSection.trash => const EmptyState(
            icon: Icons.delete_outline_rounded,
            message: AppStrings.emptyTrash,
          ),
          NoteSection.notes when isFiltered => const EmptyState(
            icon: Icons.search_off_rounded,
            message: AppStrings.emptySearch,
          ),
          NoteSection.notes => const EmptyState(
            icon: Icons.lightbulb_outline_rounded,
            message: AppStrings.emptyNotes,
          ),
        };
      },
    );
  }
}
