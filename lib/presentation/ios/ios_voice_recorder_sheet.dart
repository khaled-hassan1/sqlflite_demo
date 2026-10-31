import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/attachment.dart';
import '../../logic/recorder_controller.dart';

class IosVoiceRecorderSheet extends StatelessWidget {
  const IosVoiceRecorderSheet({super.key});

  static Future<Attachment?> show(BuildContext context) =>
      showCupertinoModalPopup<Attachment>(
        context: context,
        builder: (_) => ChangeNotifierProvider<RecorderController>(
          create: (BuildContext providerContext) =>
              RecorderController(media: providerContext.read())..start(),
          child: const IosVoiceRecorderSheet(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final RecorderController recorder = context.read<RecorderController>();
    return Container(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              AppStrings.voiceNote,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<Duration>(
              valueListenable: recorder.elapsed,
              builder: (_, Duration elapsed, _) => Text(
                '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 12),
            Selector<RecorderController, RecorderStatus>(
              selector: (_, RecorderController r) => r.status,
              builder: (BuildContext context, RecorderStatus status, _) =>
                  Text(switch (status) {
                    RecorderStatus.idle => AppStrings.tapToRecord,
                    RecorderStatus.recording => AppStrings.recording,
                    RecorderStatus.paused => AppStrings.paused,
                    RecorderStatus.saving => AppStrings.backupWorking,
                  }),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () async {
                      await recorder.discard();
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text(AppStrings.discard),
                  ),
                ),
                Flexible(
                  child: Selector<RecorderController, RecorderStatus>(
                    selector: (_, RecorderController r) => r.status,
                    builder: (BuildContext context, RecorderStatus status, _) =>
                        CupertinoButton.filled(
                          onPressed: status == RecorderStatus.idle
                              ? recorder.start
                              : status == RecorderStatus.saving
                              ? null
                              : recorder.togglePause,
                          child: Text(
                            status == RecorderStatus.paused
                                ? AppStrings.resume
                                : status == RecorderStatus.idle
                                ? AppStrings.record
                                : AppStrings.pause,
                          ),
                        ),
                  ),
                ),
                Flexible(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () async {
                      final Attachment? saved = await recorder.finish();
                      if (context.mounted && saved != null) {
                        Navigator.pop(context, saved);
                      }
                    },
                    child: const Text(
                      AppStrings.saveRecording,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
