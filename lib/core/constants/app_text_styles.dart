import 'package:flutter/material.dart';

/// Typography scale from the design system (Noto Sans, Arabic-tuned
/// line heights). Colors are intentionally left out; they are applied by the
/// theme so the same styles work in light and dark mode.
abstract final class AppTextStyles {
  static const String fontFamily = 'NotoSansArabic';
  static const List<String> fontFallback = <String>['NotoSans'];

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.36,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.44,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle titleSm = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.66,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.27,
  );

  /// Material 3 [TextTheme] mapped to the design tokens.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLg,
    displayMedium: headlineLg,
    displaySmall: headlineLgMobile,
    headlineLarge: headlineLg,
    headlineMedium: headlineMd,
    headlineSmall: headlineLgMobile,
    titleLarge: titleLg,
    titleMedium: titleMd,
    titleSmall: titleSm,
    bodyLarge: bodyLg,
    bodyMedium: bodyMd,
    bodySmall: bodySm,
    labelLarge: labelLg,
    labelMedium: labelMd,
    labelSmall: labelSm,
  );
}
