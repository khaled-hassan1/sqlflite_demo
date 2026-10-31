import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Color themes the user can pick from the drawer. [mint] is the hand-tuned
/// design-system scheme; the rest are generated from their seed color.
enum AppThemeColor {
  orange('برتقالي', AppColors.seedOrange),
  mint('نعناعي', AppColors.lightPrimaryContainer),
  blue('أزرق', AppColors.seedBlue),
  purple('بنفسجي', AppColors.seedPurple),
  pink('وردي', AppColors.seedPink),
  amber('كهرماني', AppColors.seedAmber),
  graphite('رمادي', AppColors.seedGraphite);

  const AppThemeColor(this.label, this.seed);

  final String label;
  final Color seed;

  /// Matches the orange look of version 1, so existing users feel at home.
  static const AppThemeColor fallback = orange;

  static AppThemeColor fromName(String? name) => values.firstWhere(
    (AppThemeColor c) => c.name == name,
    orElse: () => fallback,
  );
}
