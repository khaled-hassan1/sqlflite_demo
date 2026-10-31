import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';

/// One-shot entrance animation (fade + slight rise + scale) played the first
/// time [child] is mounted. Driven by [TweenAnimationBuilder], so no
/// controller or `setState`; once finished it costs nothing.
class AppearAnimation extends StatelessWidget {
  const AppearAnimation({super.key, required this.child, this.offsetY = 12});

  final Widget child;
  final double offsetY;

  static final Tween<double> _tween = Tween<double>(begin: 0, end: 1);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: _tween,
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double t, Widget? child) {
        if (t == 1) return child!;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * offsetY),
            child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
          ),
        );
      },
      child: child,
    );
  }
}
