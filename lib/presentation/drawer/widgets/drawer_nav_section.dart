import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/models/note_query.dart';
import '../../../data/models/notes_overview.dart';
import '../../../logic/notes_provider.dart';
import 'drawer_group.dart';

/// Main notes / audio / checklists / drawings.
class DrawerNavSection extends StatelessWidget {
  const DrawerNavSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<NotesProvider, NoteCounts>(
      selector: (_, NotesProvider p) => p.counts,
      builder: (BuildContext context, NoteCounts counts, _) => DrawerGroup(
        children: <Widget>[
          DrawerNavTile(
            icon: Icons.description_outlined,
            label: AppStrings.mainNotes,
            query: const NoteQuery(),
            count: counts.notes,
          ),
          DrawerNavTile(
            icon: Icons.mic_none_rounded,
            label: AppStrings.voiceRecordings,
            query: const NoteQuery(category: NoteCategory.audio),
            count: counts.audio,
            badgeColor: context.colors.secondary,
          ),
          DrawerNavTile(
            icon: Icons.checklist_rounded,
            label: AppStrings.checklists,
            query: const NoteQuery(category: NoteCategory.checklists),
            count: counts.checklists,
          ),
          DrawerNavTile(
            icon: Icons.brush_outlined,
            label: AppStrings.drawings,
            query: const NoteQuery(category: NoteCategory.drawings),
            count: counts.drawings,
            iconColor: context.colors.tertiary,
          ),
        ],
      ),
    );
  }
}

/// Archive and trash.
class DrawerBinSection extends StatelessWidget {
  const DrawerBinSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<NotesProvider, (int, int)>(
      selector: (_, NotesProvider p) => (p.counts.archive, p.counts.trash),
      builder: (BuildContext context, (int, int) counts, _) => DrawerGroup(
        children: <Widget>[
          DrawerNavTile(
            icon: Icons.archive_outlined,
            label: AppStrings.archive,
            query: const NoteQuery(section: NoteSection.archive),
            count: counts.$1,
          ),
          DrawerNavTile(
            icon: Icons.delete_outline_rounded,
            label: AppStrings.trash,
            query: const NoteQuery(section: NoteSection.trash),
            count: counts.$2,
            iconColor: context.colors.error,
            badgeColor: context.colors.error,
          ),
        ],
      ),
    );
  }
}
