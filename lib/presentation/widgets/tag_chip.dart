import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_palette.dart';

/// Small "#tag" pill. Shows a remove button when [onRemove] is set.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.tag,
    this.onRemove,
    this.foreground,
    this.compact = false,
  });

  final String tag;
  final VoidCallback? onRemove;
  final Color? foreground;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color fg = foreground ?? context.colors.onSurfaceVariant;
    final TextStyle? style =
        (compact ? context.texts.labelSmall : context.texts.labelMedium)
            ?.copyWith(color: fg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.08),
        borderRadius: compact ? AppRadius.smAll : AppRadius.lgAll,
        border: Border.all(color: fg.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: compact ? AppSpacing.sm - 2 : AppSpacing.md,
          end: onRemove == null
              ? (compact ? AppSpacing.sm - 2 : AppSpacing.md)
              : AppSpacing.xs,
          top: compact ? AppSpacing.xxs : AppSpacing.xs,
          bottom: compact ? AppSpacing.xxs : AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${AppStrings.tagPrefix}$tag',
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRemove != null)
              InkResponse(
                onTap: onRemove,
                radius: AppSizes.iconSm,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.xs,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: AppSizes.iconSm,
                    color: fg,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
