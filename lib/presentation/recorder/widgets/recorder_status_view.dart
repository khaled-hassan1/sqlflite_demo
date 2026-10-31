import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/recorder_controller.dart';

/// Elapsed time (ticks via ValueListenable) and a status caption.
class RecorderStatusView extends StatelessWidget {
  const RecorderStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    final RecorderController recorder = context.read<RecorderController>();
    return Column(
      children: <Widget>[
        ValueListenableBuilder<Duration>(
          valueListenable: recorder.elapsed,
          builder: (BuildContext context, Duration elapsed, _) => Text(
            Formatters.duration(elapsed),
            style: context.texts.displaySmall?.copyWith(
              color: context.colors.primary,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ),
        Selector<RecorderController, RecorderStatus>(
          selector: (_, RecorderController r) => r.status,
          builder: (BuildContext context, RecorderStatus status, _) => Text(
            switch (status) {
              RecorderStatus.recording => AppStrings.recording,
              RecorderStatus.paused => AppStrings.paused,
              RecorderStatus.saving => AppStrings.recording,
              RecorderStatus.idle => AppStrings.tapToRecord,
            },
            style: context.texts.labelLarge?.copyWith(
              color: status == RecorderStatus.recording
                  ? context.colors.error
                  : context.colors.outline,
            ),
          ),
        ),
      ],
    );
  }
}
