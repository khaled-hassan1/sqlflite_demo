import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/attachment.dart';
import '../../logic/recorder_controller.dart';
import '../widgets/waveform.dart';
import 'widgets/record_button.dart';
import 'widgets/recorder_actions.dart';
import 'widgets/recorder_status_view.dart';
import '../widgets/app_bottom_sheet.dart';

/// Bottom sheet that records a voice note. Pops with the saved
/// [Attachment], or `null` when discarded. Closing the sheet any other way
/// disposes the controller, which deletes the partial recording.
class VoiceRecorderSheet extends StatelessWidget {
  const VoiceRecorderSheet({super.key});

  static Future<Attachment?> show(BuildContext context) {
    return showAppBottomSheet<Attachment>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider<RecorderController>(
        create: (BuildContext context) =>
            RecorderController(media: context.read())..start(),
        child: const VoiceRecorderSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RecorderController recorder = context.read<RecorderController>();
    final AppPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(AppStrings.voiceNote, style: context.texts.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              Icon(
                Icons.offline_bolt_outlined,
                size: AppSizes.iconSm,
                color: context.colors.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AppStrings.recordingLocal,
                style: context.texts.labelMedium?.copyWith(
                  color: context.colors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Center(child: RecordButton()),
          const SizedBox(height: AppSpacing.lg),
          const RecorderStatusView(),
          const SizedBox(height: AppSpacing.lg),
          Waveform(
            levels: recorder.levels,
            activeColor: palette.waveActive,
            inactiveColor: palette.waveInactive,
          ),
          const SizedBox(height: AppSpacing.xl),
          const RecorderActions(),
        ],
      ),
    );
  }
}
