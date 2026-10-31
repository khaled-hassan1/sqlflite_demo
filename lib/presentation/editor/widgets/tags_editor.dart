import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../logic/note_editor_controller.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/appear_animation.dart';

class TagsEditor extends StatelessWidget {
  const TagsEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<NoteEditorController, List<String>>(
      selector: (_, NoteEditorController c) => c.note.tags,
      builder: (BuildContext context, List<String> tags, _) {
        final NoteEditorController editor = context
            .read<NoteEditorController>();
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final String tag in tags)
              AppearAnimation(
                key: ValueKey<String>(tag),
                offsetY: 0,
                child: TagChip(tag: tag, onRemove: () => editor.removeTag(tag)),
              ),
            ActionChip(
              avatar: const Icon(Icons.add_rounded),
              label: const Text(AppStrings.addTag),
              onPressed: () async {
                final String? tag = await showTextInputDialog(
                  context,
                  title: AppStrings.addTag,
                  hint: AppStrings.tagHint,
                );
                if (tag != null) editor.addTag(tag);
              },
            ),
          ],
        );
      },
    );
  }
}
