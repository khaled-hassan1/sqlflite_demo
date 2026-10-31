import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/checklist_item.dart';

/// Read-only checklist preview: pending items first, completed ones sink to
/// the bottom with strike-through and 50% opacity (per design).
class CardChecklistPreview extends StatelessWidget {
  const CardChecklistPreview({
    super.key,
    required this.items,
    required this.color,
  });

  final List<ChecklistItem> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final List<ChecklistItem> visible = <ChecklistItem>[
      ...items.where((ChecklistItem i) => !i.isDone && !i.isBlank),
      ...items.where((ChecklistItem i) => i.isDone && !i.isBlank),
    ];
    final int hidden = visible.length - AppConfig.cardMaxChecklistItems;
    final TextStyle? base = context.texts.bodyMedium?.copyWith(color: color);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final ChecklistItem item in visible.take(
            AppConfig.cardMaxChecklistItems,
          ))
            _Row(item: item, color: color, style: base),
          if (hidden > 0)
            Text(
              '+ ${Formatters.number(hidden)}',
              style: context.texts.labelMedium?.copyWith(
                color: color.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.color, required this.style});

  final ChecklistItem item;
  final Color color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final bool done = item.isDone;
    return Opacity(
      opacity: done ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Icon(
                done
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: AppSizes.iconSm,
                color: done ? context.colors.primary : color,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                item.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: done
                    ? style?.copyWith(decoration: TextDecoration.lineThrough)
                    : style,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
