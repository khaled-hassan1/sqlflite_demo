import 'package:flutter/widgets.dart';

/// Spacing scale (design tokens `space-*`, `gutter`, `margin`).
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const double gutter = 12;
  static const double gutterMd = 16;
  static const double margin = 16;
  static const double marginMd = 24;
}

/// Corner radii (design tokens `rounded-*`).
abstract final class AppRadius {
  static const double sm = 4;
  static const double base = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double search = 28;
  static const double pill = 32;
  static const double full = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius baseAll = BorderRadius.all(Radius.circular(base));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius searchAll = BorderRadius.all(
    Radius.circular(search),
  );
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
  static const BorderRadius mdTop = BorderRadius.vertical(
    top: Radius.circular(md),
  );
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

/// Fixed component sizes.
abstract final class AppSizes {
  static const double iconXs = 14;
  static const double iconSm = 18;
  static const double icon = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  static const double avatar = 36;
  static const double logo = 36;
  static const double logoLarge = 48;
  static const double logoRadiusFactor = 0.28;
  static const double logoCacheScale = 3;
  static const double themeSwatch = 40;
  static const double themeSwatchBorder = 1;
  static const double themeSwatchBorderSelected = 3;
  static const double searchBarHeight = 56;
  static const double filterChipsHeight = 40;
  static const double colorDot = 36;
  static const double checkbox = 22;
  static const double playButton = 44;
  static const double playButtonLarge = 64;
  static const double recordButton = 112;
  static const double bottomBarHeight = 72;
  static const double waveformHeight = 56;
  static const double waveformHeightSmall = 28;
  static const double cardImageMaxHeight = 180;
  static const double editorImageHeight = 180;
  static const double attachmentTileWidth = 160;
  static const double storageBarHeight = 12;
  static const double drawerWidth = 320;
  static const double maxContentWidth = 1440;

  /// Decode sizes used by `Image.file(cacheWidth:)` to keep memory low.
  static const int thumbnailCacheWidth = 480;
  static const int editorImageCacheWidth = 720;
}

/// Responsive breakpoints from the design spec.
abstract final class AppBreakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;

  static int columnsFor(double width, {required bool isGrid}) {
    if (!isGrid) return width >= desktop ? 2 : 1;
    if (width >= desktop) return 5;
    if (width >= tablet) return 3;
    return 2;
  }
}

/// Reusable paddings.
abstract final class AppInsets {
  static const EdgeInsets screen = EdgeInsets.symmetric(
    horizontal: AppSpacing.margin,
  );
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets section = EdgeInsets.fromLTRB(
    AppSpacing.margin,
    AppSpacing.lg,
    AppSpacing.margin,
    AppSpacing.sm,
  );
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.xs,
  );
  static const EdgeInsets allSm = EdgeInsets.all(AppSpacing.sm);
  static const EdgeInsets allMd = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets allLg = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets allXl = EdgeInsets.all(AppSpacing.xl);
}
