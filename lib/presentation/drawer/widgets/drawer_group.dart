import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/note_query.dart';
import '../../../logic/notes_provider.dart';

/// Rounded surface grouping drawer rows (shared by every drawer section).
class DrawerGroup extends StatelessWidget {
  const DrawerGroup({
    super.key,
    required this.children,
    this.padding = AppInsets.allSm,
    this.color,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Material (not DecoratedBox) so ListTile backgrounds and ink splashes
    // paint on this surface instead of being hidden beneath it.
    return Material(
      color: color ?? context.colors.surfaceContainerLow,
      borderRadius: AppRadius.xlAll,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Navigation row that highlights itself when [query] is the current one.
class DrawerNavTile extends StatelessWidget {
  const DrawerNavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.query,
    this.count = 0,
    this.iconColor,
    this.badgeColor,
  });

  final IconData icon;
  final String label;
  final NoteQuery query;
  final int count;
  final Color? iconColor;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Selector<NotesProvider, bool>(
      selector: (_, NotesProvider p) => p.query == query,
      builder: (BuildContext context, bool selected, _) => ListTile(
        selected: selected,
        selectedTileColor: palette.accent,
        selectedColor: palette.onAccent,
        leading: Icon(icon, color: selected ? palette.onAccent : iconColor),
        title: Text(label),
        trailing: count > 0
            ? _CountBadge(count: count, selected: selected, color: badgeColor)
            : null,
        onTap: () {
          context.read<NotesProvider>().setQuery(query);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.selected, this.color});

  final int count;
  final bool selected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final String text = Formatters.number(count);
    if (!selected && color == null) {
      return Text(
        text,
        style: context.texts.labelMedium?.copyWith(
          color: context.colors.outline,
        ),
      );
    }
    final Color bg = selected
        ? context.colors.primary
        : color!.withValues(alpha: 0.15);
    final Color fg = selected ? context.colors.onPrimary : color!;
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.fullAll),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          text,
          style: context.texts.labelMedium?.copyWith(color: fg),
        ),
      ),
    );
  }
}
