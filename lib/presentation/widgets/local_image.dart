import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_palette.dart';

/// Displays a locally stored image, decoded at a reduced size
/// ([cacheWidth]) to save memory, with a graceful fallback when the file is
/// missing or corrupted.
class LocalImage extends StatelessWidget {
  const LocalImage({
    super.key,
    required this.path,
    this.cacheWidth = AppSizes.thumbnailCacheWidth,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String path;
  final int cacheWidth;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      frameBuilder: _fadeIn,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) => _Broken(width: width, height: height),
    );
  }

  static Widget _fadeIn(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: AppDurations.medium,
      curve: Curves.easeOut,
      child: child,
    );
  }
}

class _Broken extends StatelessWidget {
  const _Broken({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? AppSizes.iconXl * 2,
      color: context.colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_outlined, color: context.colors.outline),
    );
  }
}
