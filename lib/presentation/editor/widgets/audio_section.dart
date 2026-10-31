import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../data/models/attachment.dart';
import '../../../logic/note_editor_controller.dart';
import '../../widgets/audio_player.dart';
import '../../widgets/appear_animation.dart';

/// Voice recordings attached to the note, each with a full player.
class AudioSection extends StatelessWidget {
  const AudioSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<NoteEditorController, List<Attachment>>(
      selector: (_, NoteEditorController c) => c.note.attachments,
      builder: (BuildContext context, List<Attachment> attachments, _) {
        final NoteEditorController editor = context
            .read<NoteEditorController>();
        final List<Attachment> audios = attachments
            .where((Attachment a) => a.type == AttachmentType.audio)
            .toList(growable: false);
        if (audios.isEmpty) return const SizedBox.shrink();
        return Column(
          children: <Widget>[
            for (final Attachment audio in audios)
              Padding(
                key: ValueKey<String>(audio.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppearAnimation(
                  child: AudioPlayerCard(
                    attachment: audio,
                    path: editor.media.pathOf(audio.fileName),
                    onDelete: () => editor.removeAttachment(audio),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
