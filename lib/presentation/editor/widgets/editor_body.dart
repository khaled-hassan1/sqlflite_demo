import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/note_editor_controller.dart';
import '../../widgets/status_badge.dart';
import 'attachments_section.dart';
import 'audio_section.dart';
import 'checklist_editor.dart';
import 'tags_editor.dart';

/// Scrollable editor content. Every section selects only its own slice of
/// the note, so e.g. adding a tag never rebuilds the checklist.
class EditorBody extends StatelessWidget {
  const EditorBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        0,
        AppSpacing.margin,
        AppSpacing.xl,
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      children: const <Widget>[
        _MetaRow(),
        SizedBox(height: AppSpacing.md),
        _TitleField(),
        SizedBox(height: AppSpacing.sm),
        AudioSection(),
        _ContentSwitcher(),
        AttachmentsSection(),
        SizedBox(height: AppSpacing.lg),
        TagsEditor(),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Selector<NoteEditorController, DateTime>(
          selector: (_, NoteEditorController c) => c.note.updatedAt,
          builder: (BuildContext context, DateTime updated, _) => StatusBadge(
            icon: Icons.schedule_rounded,
            label: Formatters.relativeDate(updated),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const StatusBadge.local(),
      ],
    );
  }
}

class _TitleField extends StatelessWidget {
  const _TitleField();

  @override
  Widget build(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    return TextField(
      controller: editor.titleController,
      maxLines: null,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      style: context.texts.headlineMedium,
      decoration: InputDecoration(
        hintText: AppStrings.titleHint,
        hintStyle: context.texts.headlineMedium?.copyWith(
          color: context.colors.outline,
        ),
      ),
    );
  }
}

class _ContentSwitcher extends StatelessWidget {
  const _ContentSwitcher();

  @override
  Widget build(BuildContext context) {
    return Selector<NoteEditorController, bool>(
      selector: (_, NoteEditorController c) => c.note.isChecklist,
      builder: (BuildContext context, bool isChecklist, _) =>
          isChecklist ? const ChecklistEditor() : const _ContentField(),
    );
  }
}

class _ContentField extends StatelessWidget {
  const _ContentField();

  @override
  Widget build(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    return TextField(
      controller: editor.contentController,
      autofocus: editor.note.isEmpty,
      maxLines: null,
      minLines: 3,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      style: context.texts.bodyLarge,
      decoration: const InputDecoration(hintText: AppStrings.contentHint),
    );
  }
}
