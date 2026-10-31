import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/models/note_query.dart';
import '../../../data/models/notes_overview.dart';
import '../../../logic/notes_provider.dart';
import '../../widgets/section_header.dart';
import 'drawer_group.dart';

/// Every label in use, with counts. Tapping filters the home screen.
class DrawerLabelsSection extends StatelessWidget {
  const DrawerLabelsSection({super.key});

  static const List<Color> _cycle = <Color>[
    AppColors.brandPine,
    AppColors.brandOchre,
    AppColors.brandIris,
  ];

  @override
  Widget build(BuildContext context) {
    return Selector<NotesProvider, List<TagCount>>(
      selector: (_, NotesProvider p) => p.tags,
      builder: (BuildContext context, List<TagCount> tags, _) => DrawerGroup(
        children: <Widget>[
          const SectionHeader(
            title: AppStrings.labels,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
          ),
          if (tags.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                AppStrings.noLabels,
                style: context.texts.bodySmall?.copyWith(
                  color: context.colors.outline,
                ),
              ),
            ),
          for (int i = 0; i < tags.length; i++)
            DrawerNavTile(
              icon: Icons.label_outline_rounded,
              iconColor: _cycle[i % _cycle.length],
              label: '${AppStrings.tagPrefix}${tags[i].tag}',
              query: NoteQuery(tag: tags[i].tag),
              count: tags[i].count,
            ),
        ],
      ),
    );
  }
}
