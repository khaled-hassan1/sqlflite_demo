import 'package:flutter/material.dart';

/// Raw color tokens taken from the "Tadween Material Note" design system.
///
/// Widgets must not use these directly — they read colors from
/// [Theme.of(context).colorScheme] or from `AppPalette` so light/dark
/// switching stays centralized.
abstract final class AppColors {
  // ───────────────────────── Light scheme ─────────────────────────
  static const Color lightPrimary = Color(0xFF005045);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFF1F695C);
  static const Color lightOnPrimaryContainer = Color(0xFF9FE6D5);
  static const Color lightSecondary = Color(0xFF904D00);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFFE932C);
  static const Color lightOnSecondaryContainer = Color(0xFF663500);
  static const Color lightTertiary = Color(0xFF5A00C5);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFF732EE4);
  static const Color lightOnTertiaryContainer = Color(0xFFE2D1FF);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF93000A);
  static const Color lightSurface = Color(0xFFFDF8FD);
  static const Color lightSurfaceDim = Color(0xFFDDD9DE);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF7F2F8);
  static const Color lightSurfaceContainer = Color(0xFFF1ECF2);
  static const Color lightSurfaceContainerHigh = Color(0xFFEBE7EC);
  static const Color lightSurfaceContainerHighest = Color(0xFFE5E1E7);
  static const Color lightOnSurface = Color(0xFF1C1B1F);
  static const Color lightOnSurfaceVariant = Color(0xFF3F4946);
  static const Color lightOutline = Color(0xFF6F7976);
  static const Color lightOutlineVariant = Color(0xFFBEC9C5);
  static const Color lightInverseSurface = Color(0xFF313034);
  static const Color lightOnInverseSurface = Color(0xFFF4EFF5);
  static const Color lightInversePrimary = Color(0xFF8ED4C4);

  // ───────────────────────── Dark scheme ─────────────────────────
  static const Color darkPrimary = Color(0xFF8ED4C4);
  static const Color darkOnPrimary = Color(0xFF00382F);
  static const Color darkPrimaryContainer = Color(0xFF005045);
  static const Color darkOnPrimaryContainer = Color(0xFFA9F0DF);
  static const Color darkSecondary = Color(0xFFFFB77D);
  static const Color darkOnSecondary = Color(0xFF4D2600);
  static const Color darkSecondaryContainer = Color(0xFF6E3900);
  static const Color darkOnSecondaryContainer = Color(0xFFFFDCC3);
  static const Color darkTertiary = Color(0xFFD2BBFF);
  static const Color darkOnTertiary = Color(0xFF3F008D);
  static const Color darkTertiaryContainer = Color(0xFF5A00C6);
  static const Color darkOnTertiaryContainer = Color(0xFFEADDFF);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceDim = Color(0xFF121212);
  static const Color darkSurfaceBright = Color(0xFF3A393D);
  static const Color darkSurfaceContainerLowest = Color(0xFF0D0D0F);
  static const Color darkSurfaceContainerLow = Color(0xFF1A191C);
  static const Color darkSurfaceContainer = Color(0xFF1E1F22);
  static const Color darkSurfaceContainerHigh = Color(0xFF28272B);
  static const Color darkSurfaceContainerHighest = Color(0xFF333236);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOnSurfaceVariant = Color(0xFFBEC9C5);
  static const Color darkOutline = Color(0xFF899390);
  static const Color darkOutlineVariant = Color(0xFF3F4946);
  static const Color darkInverseSurface = Color(0xFFE6E1E5);
  static const Color darkOnInverseSurface = Color(0xFF313034);
  static const Color darkInversePrimary = Color(0xFF1F695C);

  // ───────────────────────── Fixed (mode independent) ─────────────────────────
  static const Color primaryFixed = Color(0xFFA9F0DF);
  static const Color primaryFixedDim = Color(0xFF8ED4C4);
  static const Color onPrimaryFixed = Color(0xFF00201B);
  static const Color onPrimaryFixedVariant = Color(0xFF005045);
  static const Color secondaryFixed = Color(0xFFFFDCC3);
  static const Color secondaryFixedDim = Color(0xFFFFB77D);
  static const Color onSecondaryFixed = Color(0xFF2F1500);
  static const Color onSecondaryFixedVariant = Color(0xFF6E3900);
  static const Color tertiaryFixed = Color(0xFFEADDFF);
  static const Color tertiaryFixedDim = Color(0xFFD2BBFF);
  static const Color onTertiaryFixed = Color(0xFF25005A);
  static const Color onTertiaryFixedVariant = Color(0xFF5A00C6);

  // ───────────────────────── Brand accents ─────────────────────────
  static const Color brandPine = Color(0xFF1F695C);
  static const Color brandPineDeep = Color(0xFF13473E);
  static const Color brandOchre = Color(0xFFD97706);
  static const Color brandAmber = Color(0xFFF59E0B);
  static const Color brandIris = Color(0xFF7C3AED);
  static const Color logoYellow = Color(0xFFFBC02D);
  static const Color logoCream = Color(0xFFFFFDE7);
  // Seeds of the selectable color themes.
  static const Color seedOrange = Color(0xFFE4491A);
  static const Color seedBlue = Color(0xFF1A73E8);
  static const Color seedPurple = Color(0xFF6750A4);
  static const Color seedPink = Color(0xFFD81B60);
  static const Color seedAmber = Color(0xFFF2B705);
  static const Color seedGraphite = Color(0xFF5F6368);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ───────────────────────── Note pastel matrix ─────────────────────────
  static const Color noteDefaultLight = Color(0xFFF3F4F6);
  static const Color noteDefaultDark = Color(0xFF1E1F22);

  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color amberOnLight = Color(0xFF78350F);
  static const Color amberDark = Color(0xFF3D2605);
  static const Color amberOnDark = Color(0xFFFDE68A);

  static const Color mintLight = Color(0xFFD1FAE5);
  static const Color mintOnLight = Color(0xFF065F46);
  static const Color mintDark = Color(0xFF064E3B);
  static const Color mintOnDark = Color(0xFFA7F3D0);

  static const Color coralLight = Color(0xFFFFE4E6);
  static const Color coralOnLight = Color(0xFF9F1239);
  static const Color coralDark = Color(0xFF4C0519);
  static const Color coralOnDark = Color(0xFFFECDD3);

  static const Color lavenderLight = Color(0xFFEDE9FE);
  static const Color lavenderOnLight = Color(0xFF5B21B6);
  static const Color lavenderDark = Color(0xFF2E1065);
  static const Color lavenderOnDark = Color(0xFFDDD6FE);

  static const Color skyLight = Color(0xFFE0F2FE);
  static const Color skyOnLight = Color(0xFF075985);
  static const Color skyDark = Color(0xFF082F49);
  static const Color skyOnDark = Color(0xFFBAE6FD);

  static const Color sageLight = Color(0xFFE2E8F0);
  static const Color sageOnLight = Color(0xFF334155);
  static const Color sageDark = Color(0xFF1E293B);
  static const Color sageOnDark = Color(0xFFCBD5E1);

  static const Color peachLight = Color(0xFFFFDCC3);
  static const Color peachOnLight = Color(0xFF6E3900);
  static const Color peachDark = Color(0xFF4A2600);
  static const Color peachOnDark = Color(0xFFFFDCC3);

  // ───────────────────────── Borders / overlays ─────────────────────────
  static const Color cardBorderLight = Color(0x0A000000); // rgba(0,0,0,.04)
  static const Color cardBorderDark = Color(
    0x14FFFFFF,
  ); // rgba(255,255,255,.08)
  static const Color scrimLight = Color(0x1F1C1B1F);
  static const Color imageOverlay = Color(0x8A000000);
  static const Color drawingCanvasLight = Color(0xFFFFFFFF);
  static const Color drawingCanvasDark = Color(0xFF1E1F22);

  /// Brush colors offered by the drawing canvas.
  static const List<Color> brushColors = <Color>[
    Color(0xFF1C1B1F),
    Color(0xFF1F695C),
    Color(0xFFD97706),
    Color(0xFFBA1A1A),
    Color(0xFF7C3AED),
    Color(0xFF0369A1),
    Color(0xFFE6E1E5),
  ];
}
