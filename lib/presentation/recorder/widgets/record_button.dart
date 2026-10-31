import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../logic/recorder_controller.dart';

/// Big mic button with a halo that breathes with the live input level.
class RecordButton extends StatelessWidget {
  const RecordButton({super.key});

  static const double _haloSize = AppSizes.recordButton * 1.6;

  @override
  Widget build(BuildContext context) {
    final RecorderController recorder = context.read<RecorderController>();
    final ColorScheme colors = context.colors;
    return SizedBox.square(
      dimension: _haloSize,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          RepaintBoundary(
            child: ValueListenableBuilder<List<double>>(
              valueListenable: recorder.levels,
              builder:
                  (BuildContext context, List<double> levels, Widget? halo) =>
                      AnimatedScale(
                        duration: AppDurations.fast,
                        scale: 0.7 + 0.3 * levels.last,
                        child: halo,
                      ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.palette.recordHalo.withValues(alpha: 0.6),
                ),
                child: const SizedBox.square(dimension: _haloSize),
              ),
            ),
          ),
          Selector<RecorderController, RecorderStatus>(
            selector: (_, RecorderController r) => r.status,
            builder: (BuildContext context, RecorderStatus status, _) {
              final bool isRecording = status == RecorderStatus.recording;
              return SizedBox.square(
                dimension: AppSizes.recordButton,
                child: IconButton.filled(
                  tooltip: isRecording ? AppStrings.pause : AppStrings.resume,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  onPressed: status == RecorderStatus.saving
                      ? null
                      : (status == RecorderStatus.idle
                            ? recorder.start
                            : recorder.togglePause),
                  icon: Icon(
                    isRecording ? Icons.pause_rounded : Icons.mic_rounded,
                    size: AppSizes.iconXl,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
