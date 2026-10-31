import 'dart:ui';

import '../../core/constants/app_colors.dart';

/// Pastel accent a note can be tinted with (design "Note Pastel Accent Matrix").
enum NoteColor {
  none(
    light: AppColors.noteDefaultLight,
    onLight: AppColors.lightOnSurface,
    dark: AppColors.noteDefaultDark,
    onDark: AppColors.darkOnSurface,
  ),
  coral(
    light: AppColors.coralLight,
    onLight: AppColors.coralOnLight,
    dark: AppColors.coralDark,
    onDark: AppColors.coralOnDark,
  ),
  peach(
    light: AppColors.peachLight,
    onLight: AppColors.peachOnLight,
    dark: AppColors.peachDark,
    onDark: AppColors.peachOnDark,
  ),
  amber(
    light: AppColors.amberLight,
    onLight: AppColors.amberOnLight,
    dark: AppColors.amberDark,
    onDark: AppColors.amberOnDark,
  ),
  mint(
    light: AppColors.mintLight,
    onLight: AppColors.mintOnLight,
    dark: AppColors.mintDark,
    onDark: AppColors.mintOnDark,
  ),
  sky(
    light: AppColors.skyLight,
    onLight: AppColors.skyOnLight,
    dark: AppColors.skyDark,
    onDark: AppColors.skyOnDark,
  ),
  lavender(
    light: AppColors.lavenderLight,
    onLight: AppColors.lavenderOnLight,
    dark: AppColors.lavenderDark,
    onDark: AppColors.lavenderOnDark,
  ),
  sage(
    light: AppColors.sageLight,
    onLight: AppColors.sageOnLight,
    dark: AppColors.sageDark,
    onDark: AppColors.sageOnDark,
  );

  const NoteColor({
    required this.light,
    required this.onLight,
    required this.dark,
    required this.onDark,
  });

  final Color light;
  final Color onLight;
  final Color dark;
  final Color onDark;

  Color container(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  Color onContainer(Brightness brightness) =>
      brightness == Brightness.dark ? onDark : onLight;

  static NoteColor fromName(String? name) {
    for (final NoteColor color in values) {
      if (color.name == name) return color;
    }
    return NoteColor.none;
  }
}
