import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Semantic colors that Material's [ColorScheme] does not cover.
@immutable
final class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.cardBorder,
    required this.accent,
    required this.onAccent,
    required this.localBadge,
    required this.onLocalBadge,
    required this.storageAudio,
    required this.storageImages,
    required this.storageText,
    required this.waveActive,
    required this.waveInactive,
    required this.waveHighlight,
    required this.recordHalo,
    required this.canvas,
    required this.fileIconBackground,
    required this.fileIconForeground,
  });

  /// Hairline border of note cards.
  final Color cardBorder;

  /// Mint accent used by selected chips, active drawer item and FAB.
  final Color accent;
  final Color onAccent;

  /// Amber "local only" badge.
  final Color localBadge;
  final Color onLocalBadge;

  /// Storage usage bar segments.
  final Color storageAudio;
  final Color storageImages;
  final Color storageText;

  /// Audio waveform bars.
  final Color waveActive;
  final Color waveInactive;
  final Color waveHighlight;

  /// Soft halo drawn behind the record button.
  final Color recordHalo;

  /// Drawing canvas background.
  final Color canvas;

  final Color fileIconBackground;
  final Color fileIconForeground;

  static const AppPalette light = AppPalette(
    cardBorder: AppColors.cardBorderLight,
    accent: AppColors.primaryFixed,
    onAccent: AppColors.onPrimaryFixed,
    localBadge: AppColors.secondaryFixed,
    onLocalBadge: AppColors.onSecondaryFixedVariant,
    storageAudio: AppColors.lightSecondary,
    storageImages: AppColors.lightPrimaryContainer,
    storageText: AppColors.lightTertiary,
    waveActive: AppColors.lightPrimary,
    waveInactive: AppColors.lightOutlineVariant,
    waveHighlight: AppColors.brandAmber,
    recordHalo: AppColors.primaryFixed,
    canvas: AppColors.drawingCanvasLight,
    fileIconBackground: AppColors.secondaryFixed,
    fileIconForeground: AppColors.onSecondaryFixedVariant,
  );

  static const AppPalette dark = AppPalette(
    cardBorder: AppColors.cardBorderDark,
    accent: AppColors.darkPrimaryContainer,
    onAccent: AppColors.darkOnPrimaryContainer,
    localBadge: AppColors.darkSecondaryContainer,
    onLocalBadge: AppColors.darkOnSecondaryContainer,
    storageAudio: AppColors.darkSecondary,
    storageImages: AppColors.darkPrimary,
    storageText: AppColors.darkTertiary,
    waveActive: AppColors.darkPrimary,
    waveInactive: AppColors.darkOutlineVariant,
    waveHighlight: AppColors.brandAmber,
    recordHalo: AppColors.darkPrimaryContainer,
    canvas: AppColors.drawingCanvasDark,
    fileIconBackground: AppColors.darkSecondaryContainer,
    fileIconForeground: AppColors.darkOnSecondaryContainer,
  );

  /// Palette derived from a generated scheme (non-mint color themes).
  factory AppPalette.fromScheme(ColorScheme scheme) {
    final bool isDark = scheme.brightness == Brightness.dark;
    return AppPalette(
      cardBorder: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
      accent: scheme.primaryContainer,
      onAccent: scheme.onPrimaryContainer,
      localBadge: scheme.secondaryContainer,
      onLocalBadge: scheme.onSecondaryContainer,
      storageAudio: scheme.secondary,
      storageImages: scheme.primary,
      storageText: scheme.tertiary,
      waveActive: scheme.primary,
      waveInactive: scheme.outlineVariant,
      waveHighlight: scheme.tertiary,
      recordHalo: scheme.primaryContainer,
      canvas: isDark
          ? AppColors.drawingCanvasDark
          : AppColors.drawingCanvasLight,
      fileIconBackground: scheme.secondaryContainer,
      fileIconForeground: scheme.onSecondaryContainer,
    );
  }

  @override
  AppPalette copyWith({
    Color? cardBorder,
    Color? accent,
    Color? onAccent,
    Color? localBadge,
    Color? onLocalBadge,
    Color? storageAudio,
    Color? storageImages,
    Color? storageText,
    Color? waveActive,
    Color? waveInactive,
    Color? waveHighlight,
    Color? recordHalo,
    Color? canvas,
    Color? fileIconBackground,
    Color? fileIconForeground,
  }) {
    return AppPalette(
      cardBorder: cardBorder ?? this.cardBorder,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      localBadge: localBadge ?? this.localBadge,
      onLocalBadge: onLocalBadge ?? this.onLocalBadge,
      storageAudio: storageAudio ?? this.storageAudio,
      storageImages: storageImages ?? this.storageImages,
      storageText: storageText ?? this.storageText,
      waveActive: waveActive ?? this.waveActive,
      waveInactive: waveInactive ?? this.waveInactive,
      waveHighlight: waveHighlight ?? this.waveHighlight,
      recordHalo: recordHalo ?? this.recordHalo,
      canvas: canvas ?? this.canvas,
      fileIconBackground: fileIconBackground ?? this.fileIconBackground,
      fileIconForeground: fileIconForeground ?? this.fileIconForeground,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      localBadge: Color.lerp(localBadge, other.localBadge, t)!,
      onLocalBadge: Color.lerp(onLocalBadge, other.onLocalBadge, t)!,
      storageAudio: Color.lerp(storageAudio, other.storageAudio, t)!,
      storageImages: Color.lerp(storageImages, other.storageImages, t)!,
      storageText: Color.lerp(storageText, other.storageText, t)!,
      waveActive: Color.lerp(waveActive, other.waveActive, t)!,
      waveInactive: Color.lerp(waveInactive, other.waveInactive, t)!,
      waveHighlight: Color.lerp(waveHighlight, other.waveHighlight, t)!,
      recordHalo: Color.lerp(recordHalo, other.recordHalo, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      fileIconBackground: Color.lerp(
        fileIconBackground,
        other.fileIconBackground,
        t,
      )!,
      fileIconForeground: Color.lerp(
        fileIconForeground,
        other.fileIconForeground,
        t,
      )!,
    );
  }
}

/// Short-hands for reading theme data.
extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
