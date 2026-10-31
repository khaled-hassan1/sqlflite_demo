import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../data/models/attachment.dart';
import '../../../logic/recorder_controller.dart';

/// "Discard" and "Save" buttons.
class RecorderActions extends StatelessWidget {
  const RecorderActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<RecorderController, RecorderStatus>(
      selector: (_, RecorderController r) => r.status,
      builder: (BuildContext context, RecorderStatus status, _) {
        final RecorderController recorder = context.read<RecorderController>();
        final bool canSave = recorder.isActive;
        return Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: status == RecorderStatus.saving
                    ? null
                    : () async {
                        final NavigatorState navigator = Navigator.of(context);
                        await recorder.discard();
                        navigator.pop();
                      },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text(AppStrings.discard),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: canSave
                    ? () async {
                        final NavigatorState navigator = Navigator.of(context);
                        final Attachment? audio = await recorder.finish();
                        navigator.pop(audio);
                      }
                    : null,
                icon: status == RecorderStatus.saving
                    ? const SizedBox.square(
                        dimension: AppSizes.iconSm,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: const Text(
                  AppStrings.saveRecording,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
