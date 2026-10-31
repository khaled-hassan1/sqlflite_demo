import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_palette.dart';

/// Title (+ optional icon) on the start side and a trailing widget/label on
/// the end side, as used by "المثبتة", "أخرى" and editor sections.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    this.padding = AppInsets.section,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: AppSizes.iconSm, color: context.colors.primary),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(
              title,
              style: context.texts.titleSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Muted small label, e.g. "٢ ملاحظة".
class MutedLabel extends StatelessWidget {
  const MutedLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.texts.labelSmall?.copyWith(color: context.colors.outline),
    );
  }
}
