import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_palette.dart';

/// Compact pill with an icon and a label (e.g. "محلي فقط", edited time).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
  }) : isLocal = false;

  /// Amber "local only" badge from the design.
  const StatusBadge.local({super.key, this.label = AppStrings.localOnly})
    : icon = Icons.offline_pin_outlined,
      background = null,
      foreground = null,
      isLocal = true;

  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final Color bg =
        background ??
        (isLocal ? palette.localBadge : context.colors.surfaceContainerHigh);
    final Color fg =
        foreground ??
        (isLocal ? palette.onLocalBadge : context.colors.onSurfaceVariant);
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.fullAll),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md - 2,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: AppSizes.iconXs, color: fg),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: context.texts.labelMedium?.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}
