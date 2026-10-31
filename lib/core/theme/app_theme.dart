import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import 'app_palette.dart';
import 'app_theme_color.dart';

/// Builds the [ThemeData] of every color theme lazily and caches it.
abstract final class AppTheme {
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    primaryContainer: AppColors.lightPrimaryContainer,
    onPrimaryContainer: AppColors.lightOnPrimaryContainer,
    primaryFixed: AppColors.primaryFixed,
    primaryFixedDim: AppColors.primaryFixedDim,
    onPrimaryFixed: AppColors.onPrimaryFixed,
    onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
    secondary: AppColors.lightSecondary,
    onSecondary: AppColors.lightOnSecondary,
    secondaryContainer: AppColors.lightSecondaryContainer,
    onSecondaryContainer: AppColors.lightOnSecondaryContainer,
    secondaryFixed: AppColors.secondaryFixed,
    secondaryFixedDim: AppColors.secondaryFixedDim,
    onSecondaryFixed: AppColors.onSecondaryFixed,
    onSecondaryFixedVariant: AppColors.onSecondaryFixedVariant,
    tertiary: AppColors.lightTertiary,
    onTertiary: AppColors.lightOnTertiary,
    tertiaryContainer: AppColors.lightTertiaryContainer,
    onTertiaryContainer: AppColors.lightOnTertiaryContainer,
    tertiaryFixed: AppColors.tertiaryFixed,
    tertiaryFixedDim: AppColors.tertiaryFixedDim,
    onTertiaryFixed: AppColors.onTertiaryFixed,
    onTertiaryFixedVariant: AppColors.onTertiaryFixedVariant,
    error: AppColors.lightError,
    onError: AppColors.lightOnError,
    errorContainer: AppColors.lightErrorContainer,
    onErrorContainer: AppColors.lightOnErrorContainer,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    surfaceDim: AppColors.lightSurfaceDim,
    surfaceBright: AppColors.lightSurface,
    surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
    surfaceContainerLow: AppColors.lightSurfaceContainerLow,
    surfaceContainer: AppColors.lightSurfaceContainer,
    surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
    surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightOutlineVariant,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.lightInverseSurface,
    onInverseSurface: AppColors.lightOnInverseSurface,
    inversePrimary: AppColors.lightInversePrimary,
    surfaceTint: AppColors.lightPrimaryContainer,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    primaryContainer: AppColors.darkPrimaryContainer,
    onPrimaryContainer: AppColors.darkOnPrimaryContainer,
    primaryFixed: AppColors.primaryFixed,
    primaryFixedDim: AppColors.primaryFixedDim,
    onPrimaryFixed: AppColors.onPrimaryFixed,
    onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.darkOnSecondary,
    secondaryContainer: AppColors.darkSecondaryContainer,
    onSecondaryContainer: AppColors.darkOnSecondaryContainer,
    secondaryFixed: AppColors.secondaryFixed,
    secondaryFixedDim: AppColors.secondaryFixedDim,
    onSecondaryFixed: AppColors.onSecondaryFixed,
    onSecondaryFixedVariant: AppColors.onSecondaryFixedVariant,
    tertiary: AppColors.darkTertiary,
    onTertiary: AppColors.darkOnTertiary,
    tertiaryContainer: AppColors.darkTertiaryContainer,
    onTertiaryContainer: AppColors.darkOnTertiaryContainer,
    tertiaryFixed: AppColors.tertiaryFixed,
    tertiaryFixedDim: AppColors.tertiaryFixedDim,
    onTertiaryFixed: AppColors.onTertiaryFixed,
    onTertiaryFixedVariant: AppColors.onTertiaryFixedVariant,
    error: AppColors.darkError,
    onError: AppColors.darkOnError,
    errorContainer: AppColors.darkErrorContainer,
    onErrorContainer: AppColors.darkOnErrorContainer,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    surfaceDim: AppColors.darkSurfaceDim,
    surfaceBright: AppColors.darkSurfaceBright,
    surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
    surfaceContainerLow: AppColors.darkSurfaceContainerLow,
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
    surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.darkInverseSurface,
    onInverseSurface: AppColors.darkOnInverseSurface,
    inversePrimary: AppColors.darkInversePrimary,
    surfaceTint: AppColors.darkPrimary,
  );

  static final ThemeData light = _build(_lightScheme, AppPalette.light);
  static final ThemeData dark = _build(_darkScheme, AppPalette.dark);

  static final Map<(AppThemeColor, Brightness), ThemeData> _cache =
      <(AppThemeColor, Brightness), ThemeData>{};

  static ThemeData of(AppThemeColor color, Brightness brightness) =>
      _cache.putIfAbsent((color, brightness), () {
        if (color == AppThemeColor.mint) {
          return brightness == Brightness.dark ? dark : light;
        }
        final ColorScheme scheme = ColorScheme.fromSeed(
          seedColor: color.seed,
          brightness: brightness,
        );
        return _build(scheme, AppPalette.fromScheme(scheme));
      });

  static ThemeData _build(ColorScheme scheme, AppPalette palette) {
    final bool isDark = scheme.brightness == Brightness.dark;
    final TextTheme textTheme = AppTextStyles.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      fontFamily: AppTextStyles.fontFamily,
      fontFamilyFallback: AppTextStyles.fontFallback,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: <ThemeExtension<dynamic>>[palette],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: _overlayStyle(scheme, isDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: AppColors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: palette.cardBorder),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: palette.accent,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: palette.onAccent,
        ),
        padding: AppInsets.chip,
        showCheckmark: false,
        iconTheme: IconThemeData(
          size: AppSizes.iconSm,
          color: scheme.onSurfaceVariant,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: palette.onAccent,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 3,
        shape: const CircleBorder(),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        height: AppSizes.bottomBarHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: AppColors.transparent,
        width: AppSizes.drawerWidth,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: AppColors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: AppColors.transparent,
        modalBackgroundColor: scheme.surfaceContainerLow,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        side: BorderSide(color: scheme.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : AppColors.transparent,
        ),
        checkColor: WidgetStatePropertyAll<Color>(scheme.onPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: const StadiumBorder(),
          textStyle: textTheme.titleSmall,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainer,
        surfaceTintColor: AppColors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: textTheme.bodyMedium,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        overlayShape: SliderComponentShape.noOverlay,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: scheme.onSurfaceVariant,
        size: AppSizes.icon,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionHandleColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.25),
      ),
    );
  }

  static SystemUiOverlayStyle _overlayStyle(ColorScheme scheme, bool isDark) {
    return SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: scheme.surfaceContainerLow,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );
  }
}
