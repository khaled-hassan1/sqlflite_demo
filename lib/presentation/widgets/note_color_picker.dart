import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/note_color.dart';

/// Horizontal row of color dots; the selected one shows a check mark.
class NoteColorPicker extends StatelessWidget {
  const NoteColorPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NoteColor selected;
  final ValueChanged<NoteColor> onSelected;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return SizedBox(
      height: AppSizes.colorDot + AppSpacing.sm,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppInsets.screen,
        itemCount: NoteColor.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final NoteColor color = NoteColor.values[index];
          return _ColorDot(
            color: color.container(brightness),
            isSelected: color == selected,
            isDefault: color == NoteColor.none,
            onTap: () => onSelected(color),
          );
        },
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.isDefault,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    return Semantics(
      selected: isSelected,
      button: true,
      label: isDefault ? AppStrings.colorDefault : AppStrings.changeColor,
      child: InkResponse(
        onTap: onTap,
        radius: AppSizes.colorDot / 2 + 4,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width: AppSizes.colorDot,
          height: AppSizes.colorDot,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? colors.primary : colors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: isSelected
              ? Icon(
                  Icons.check_rounded,
                  size: AppSizes.iconSm,
                  color: colors.primary,
                )
              : (isDefault
                    ? Icon(
                        Icons.format_color_reset_outlined,
                        size: AppSizes.iconSm,
                        color: colors.outline,
                      )
                    : null),
        ),
      ),
    );
  }
}
