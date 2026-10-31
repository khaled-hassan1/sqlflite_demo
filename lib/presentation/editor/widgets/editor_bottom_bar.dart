import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/models/note_color.dart';
import '../../../logic/note_editor_controller.dart';
import '../../widgets/note_color_picker.dart';
import '../editor_actions.dart';

/// Collapsible color palette + tool row + "done" button.
class EditorBottomBar extends StatelessWidget {
  const EditorBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerLow,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[Divider(), _PaletteRow(), _ToolRow()],
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow();

  @override
  Widget build(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    return ValueListenableBuilder<bool>(
      valueListenable: editor.isPaletteOpen,
      builder: (BuildContext context, bool isOpen, Widget? picker) =>
          AnimatedSize(
            duration: AppDurations.medium,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isOpen ? picker : const SizedBox(width: double.infinity),
          ),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Selector<NoteEditorController, NoteColor>(
          selector: (_, NoteEditorController c) => c.note.color,
          builder: (BuildContext context, NoteColor color, _) =>
              NoteColorPicker(selected: color, onSelected: editor.setColor),
        ),
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow();

  @override
  Widget build(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          // Tools scroll horizontally on narrow phones instead of overflowing.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  IconButton(
                    tooltip: AppStrings.changeColor,
                    icon: const Icon(Icons.palette_outlined),
                    onPressed: editor.togglePalette,
                  ),
                  Selector<NoteEditorController, bool>(
                    selector: (_, NoteEditorController c) => c.note.isChecklist,
                    builder: (BuildContext context, bool isChecklist, _) =>
                        IconButton(
                          tooltip: isChecklist
                              ? AppStrings.textMode
                              : AppStrings.checklistMode,
                          isSelected: isChecklist,
                          icon: const Icon(Icons.check_box_outlined),
                          selectedIcon: const Icon(Icons.notes_rounded),
                          onPressed: editor.toggleChecklist,
                        ),
                  ),
                  IconButton(
                    tooltip: AppStrings.drawing,
                    icon: const Icon(Icons.brush_outlined),
                    onPressed: () => EditorActions.draw(context),
                  ),
                  IconButton(
                    tooltip: AppStrings.record,
                    icon: const Icon(Icons.mic_none_rounded),
                    onPressed: () => EditorActions.record(context),
                  ),
                  IconButton(
                    tooltip: AppStrings.addImage,
                    icon: const Icon(Icons.image_outlined),
                    onPressed: () => EditorActions.addImage(context),
                  ),
                  IconButton(
                    tooltip: AppStrings.attachFile,
                    icon: const Icon(Icons.attach_file_rounded),
                    onPressed: () => EditorActions.attachFile(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Tooltip(
            message: AppStrings.autoSaved,
            child: FilledButton(
              onPressed: () => Navigator.maybePop(context),
              child: const Text(AppStrings.done),
            ),
          ),
        ],
      ),
    );
  }
}
