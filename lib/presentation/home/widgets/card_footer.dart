import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/note.dart';
import '../../widgets/tag_chip.dart';

/// Tags (start) and last-edited date (end) at the bottom of a card.
class CardFooter extends StatelessWidget {
  const CardFooter({super.key, required this.note, required this.color});

  final Note note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Color muted = color.withValues(alpha: 0.65);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                for (final String tag in note.tags.take(AppConfig.cardMaxTags))
                  TagChip(tag: tag, foreground: color, compact: true),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            Formatters.relativeDate(note.updatedAt),
            style: context.texts.labelSmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}
