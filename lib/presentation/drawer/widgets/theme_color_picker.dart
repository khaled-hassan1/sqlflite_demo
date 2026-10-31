import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme_color.dart';
import '../../../logic/settings_provider.dart';

/// Row of color swatches that switches the app's color theme.
class ThemeColorPicker extends StatelessWidget {
  const ThemeColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(AppStrings.themeColor, style: context.texts.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Selector<SettingsProvider, AppThemeColor>(
            selector: (_, SettingsProvider s) => s.themeColor,
            builder: (BuildContext context, AppThemeColor selected, _) => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final AppThemeColor color in AppThemeColor.values)
                  _Swatch(color: color, isSelected: color == selected),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.isSelected});

  final AppThemeColor color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: color.label,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: color.label,
        child: InkResponse(
          onTap: () => context.read<SettingsProvider>().setThemeColor(color),
          radius: AppSizes.themeSwatch / 2,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            width: AppSizes.themeSwatch,
            height: AppSizes.themeSwatch,
            decoration: BoxDecoration(
              color: color.seed,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? context.colors.onSurface
                    : context.colors.outlineVariant,
                width: isSelected
                    ? AppSizes.themeSwatchBorderSelected
                    : AppSizes.themeSwatchBorder,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: AppColors.white)
                : null,
          ),
        ),
      ),
    );
  }
}
