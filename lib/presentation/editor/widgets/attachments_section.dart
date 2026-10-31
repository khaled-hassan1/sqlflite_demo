import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/attachment.dart';
import '../../../logic/note_editor_controller.dart';
import '../../utils/ui_actions.dart';
import '../../widgets/file_tile.dart';
import '../../widgets/local_image.dart';
import '../../widgets/section_header.dart';
import '../editor_actions.dart';
import '../../widgets/appear_animation.dart';

/// Images, drawings and files attached to the note.
class AttachmentsSection extends StatelessWidget {
  const AttachmentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<NoteEditorController, List<Attachment>>(
      selector: (_, NoteEditorController c) => c.note.attachments,
      builder: (BuildContext context, List<Attachment> attachments, _) {
        final List<Attachment> visuals = attachments
            .where((Attachment a) => a.type.isVisual)
            .toList(growable: false);
        final List<Attachment> files = attachments
            .where((Attachment a) => a.type == AttachmentType.file)
            .toList(growable: false);
        if (visuals.isEmpty && files.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SectionHeader(
              title:
                  '${AppStrings.attachments} (${Formatters.number(visuals.length + files.length)})',
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                bottom: AppSpacing.sm,
              ),
              trailing: const MutedLabel(AppStrings.savedLocally),
            ),
            if (visuals.isNotEmpty) _VisualGrid(visuals: visuals),
            for (final Attachment file in files)
              Padding(
                key: ValueKey<String>(file.id),
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: AppearAnimation(child: _FileRow(file: file)),
              ),
          ],
        );
      },
    );
  }
}

class _VisualGrid extends StatelessWidget {
  const _VisualGrid({required this.visuals});

  final List<Attachment> visuals;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: visuals.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (BuildContext context, int index) => _VisualTile(
        key: ValueKey<String>(visuals[index].id),
        visuals: visuals,
        index: index,
      ),
    );
  }
}

class _VisualTile extends StatelessWidget {
  const _VisualTile({super.key, required this.visuals, required this.index});

  final List<Attachment> visuals;
  final int index;

  @override
  Widget build(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    final Attachment attachment = visuals[index];
    return AppearAnimation(
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Material(
                color: context.palette.canvas,
                child: InkWell(
                  onTap: () =>
                      EditorActions.openVisual(context, visuals, index),
                  child: Hero(
                    tag: attachment.id,
                    child: LocalImage(
                      path: editor.media.pathOf(attachment.fileName),
                      cacheWidth: AppSizes.editorImageCacheWidth,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: AppSpacing.xs,
                end: AppSpacing.xs,
                child: IconButton.filledTonal(
                  tooltip: AppStrings.delete,
                  visualDensity: VisualDensity.compact,
                  iconSize: AppSizes.iconSm,
                  onPressed: () => editor.removeAttachment(attachment),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.file});

  final Attachment file;

  @override
  Widget build(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    return FileTile(
      attachment: file,
      onTap: () => UiActions.openFile(editor.media.pathOf(file.fileName)),
      trailing: IconButton(
        tooltip: AppStrings.delete,
        icon: const Icon(Icons.close_rounded),
        onPressed: () => editor.removeAttachment(file),
      ),
    );
  }
}
