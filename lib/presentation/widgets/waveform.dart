import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';

/// Pill-shaped vertical bars (the design's "32 vertical pill bars").
///
/// Bars up to [progress] use [activeColor], the one at the playhead uses
/// [highlightColor], the rest [inactiveColor]. Both [levels] and [progress]
/// are listenables: ticks repaint the canvas without rebuilding widgets.
class Waveform extends StatelessWidget {
  const Waveform({
    super.key,
    required this.levels,
    required this.activeColor,
    required this.inactiveColor,
    this.highlightColor,
    this.progress,
    this.height = AppSizes.waveformHeight,
  });

  /// Bar heights (0..1). Pass a [ValueNotifier] for live data (recorder) —
  /// the painter repaints on change without rebuilding widgets.
  final ValueListenable<List<double>> levels;

  /// Listenable fraction 0..1, or `null` to paint every bar active.
  final ValueListenable<double>? progress;

  final Color activeColor;
  final Color inactiveColor;
  final Color? highlightColor;
  final double height;

  /// Stable pseudo-random bar heights derived from [seed] (e.g. a file id),
  /// so each recording always shows the same shape.
  static ValueListenable<List<double>> seeded(
    String seed, {
    int count = AppConfig.waveformBars,
  }) {
    return _cache.putIfAbsent(
      seed,
      () => _StaticLevels(_generate(seed, count)),
    );
  }

  /// Seeded shapes are cached so rebuilding a card never reallocates them.
  static final Map<String, ValueListenable<List<double>>> _cache =
      <String, ValueListenable<List<double>>>{};

  static List<double> _generate(String seed, int count) {
    final math.Random random = math.Random(seed.hashCode);
    return List<double>.generate(
      count,
      (int i) =>
          0.25 +
          0.75 *
              (0.5 + 0.5 * math.sin(i * 0.7 + random.nextDouble() * 2)) *
              random.nextDouble(),
      growable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _WaveformPainter(
            levels: levels,
            isRtl: Directionality.of(context) == TextDirection.rtl,
            progress: progress,
            active: activeColor,
            inactive: inactiveColor,
            highlight: highlightColor,
          ),
        ),
      ),
    );
  }
}

/// A never-changing [ValueListenable].
final class _StaticLevels implements ValueListenable<List<double>> {
  const _StaticLevels(this.value);

  @override
  final List<double> value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

/// Exposes `position / duration` of two listenables as a 0..1 fraction.
final class DurationFraction implements ValueListenable<double> {
  DurationFraction(this.position, this.duration)
    : _merged = Listenable.merge(<Listenable>[position, duration]);

  final ValueListenable<Duration> position;
  final ValueListenable<Duration> duration;
  final Listenable _merged;

  @override
  double get value {
    final int total = duration.value.inMilliseconds;
    return total <= 0
        ? 0
        : (position.value.inMilliseconds / total).clamp(0.0, 1.0);
  }

  @override
  void addListener(VoidCallback listener) => _merged.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _merged.removeListener(listener);
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.levels,
    required this.isRtl,
    required this.progress,
    required this.active,
    required this.inactive,
    required this.highlight,
  }) : super(
         repaint: progress == null
             ? levels
             : Listenable.merge(<Listenable?>[levels, progress]),
       );

  final ValueListenable<List<double>> levels;
  final bool isRtl;
  final ValueListenable<double>? progress;
  final Color active;
  final Color inactive;
  final Color? highlight;

  static const double _gapRatio = 0.6;

  @override
  void paint(Canvas canvas, Size size) {
    final List<double> bars = levels.value;
    if (bars.isEmpty) return;
    final int count = bars.length;
    final double slot = size.width / count;
    final double barWidth = slot * _gapRatio;
    final double fraction = progress?.value ?? 1;
    final int activeCount = (fraction * count).floor();
    final Paint paint = Paint()..isAntiAlias = true;
    final Radius radius = Radius.circular(barWidth / 2);

    for (int i = 0; i < count; i++) {
      final double h = math.max(
        barWidth,
        bars[i].clamp(0.0, 1.0) * size.height,
      );
      final double x = isRtl
          ? size.width - (i + 1) * slot + (slot - barWidth) / 2
          : i * slot + (slot - barWidth) / 2;
      final double top = (size.height - h) / 2;
      paint.color = progress == null || i < activeCount
          ? active
          : (i == activeCount && highlight != null && fraction > 0
                ? highlight!
                : inactive);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, top, barWidth, h), radius),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.levels != levels ||
      old.isRtl != isRtl ||
      old.progress != progress ||
      old.active != active ||
      old.inactive != inactive ||
      old.highlight != highlight;
}
