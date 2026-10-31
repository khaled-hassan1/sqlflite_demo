import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';

/// The app logo (same artwork as the launcher icon).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = AppSizes.logo});

  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * AppSizes.logoRadiusFactor),
        child: Image.asset(
          AppAssets.logo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: (size * AppSizes.logoCacheScale).round(),
        ),
      ),
    );
  }
}
