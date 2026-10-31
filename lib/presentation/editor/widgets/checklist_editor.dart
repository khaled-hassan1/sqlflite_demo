import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/checklist_item.dart';
import '../../../logic/note_editor_controller.dart';
import '../../widgets/appear_animation.dart';

typedef _Ids = ({List<String> pending, List<String> done});

/// Editable checklist. Pending items can be reordered by dragging their
/// handle. The list only rebuilds when rows are added, removed, moved or
/// toggled; each row rebuilds only for its own item.
class ChecklistEditor extends StatelessWidget {
  const ChecklistEditor({super.key});

  static _Ids _select(BuildContext _, NoteEditorController c) => (
    pending: c.pendingItems
        .map((ChecklistItem i) => i.id)
        .toList(growable: false),
    done: c.doneItems.map((ChecklistItem i) => i.id).toList(growable: false),
  );

  /// Elevated look of the row while it is being dragged.
  static Widget _liftedRow(Widget child, int index, Animation<double> anim) {
    return AnimatedBuilder(
      animation: anim,
      builder: (BuildContext context, Widget? child) => Material(
        elevation: 6 * Curves.easeOut.transform(anim.value),
        color: context.colors.surfaceContainerHigh,
        borderRadius: AppRadius.mdAll,
        child: child,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<NoteEditorController, _Ids>(
      selector: _select,
      shouldRebuild: (_Ids a, _Ids b) =>
          !listEquals(a.pending, b.pending) || !listEquals(a.done, b.done),
      builder: (BuildContext context, _Ids ids, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              buildDefaultDragHandles: false,
              itemCount: ids.pending.length,
              onReorderItem: context
                  .read<NoteEditorController>()
                  .reorderPending,
              proxyDecorator: _liftedRow,
              itemBuilder: (BuildContext context, int index) => _ItemRow(
                key: ValueKey<String>(ids.pending[index]),
                id: ids.pending[index],
                dragIndex: index,
              ),
            ),
            const _AddItemButton(),
            if (ids.done.isNotEmpty) ...<Widget>[
              const Divider(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  '${Formatters.number(ids.done.length)} ${AppStrings.completedItems}',
                  style: context.texts.labelLarge?.copyWith(
                    color: context.colors.outline,
                  ),
                ),
              ),
              for (final String id in ids.done)
                _ItemRow(key: ValueKey<String>(id), id: id),
            ],
          ],
        );
      },
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({super.key, required this.id, this.dragIndex});

  final String id;

  /// Position in the reorderable (pending) list; `null` for completed rows,
  /// which are not draggable.
  final int? dragIndex;

  @override
  Widget build(BuildContext context) {
    final NoteEditorController editor = context.read<NoteEditorController>();
    return Selector<NoteEditorController, bool>(
      selector: (_, NoteEditorController c) => c.note.checklist
          .firstWhere(
            (ChecklistItem i) => i.id == id,
            orElse: () => ChecklistItem(id: id, text: ''),
          )
          .isDone,
      builder: (BuildContext context, bool isDone, _) {
        final TextStyle? style = context.texts.bodyLarge;
        final int? index = dragIndex;
        return AppearAnimation(
          offsetY: 6,
          child: AnimatedOpacity(
            opacity: isDone ? 0.5 : 1,
            duration: AppDurations.fast,
            child: Row(
              children: <Widget>[
                if (index != null)
                  ReorderableDragStartListener(
                    index: index,
                    child: Tooltip(
                      message: AppStrings.dragHandle,
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: context.colors.outline,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: AppSizes.icon),
                Checkbox(
                  value: isDone,
                  onChanged: (_) => editor.toggleItem(id),
                ),
                Expanded(
                  child: TextField(
                    controller: editor.itemController(id),
                    focusNode: editor.itemFocus(id),
                    maxLines: null,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => editor.addItem(afterId: id),
                    style: isDone
                        ? style?.copyWith(
                            decoration: TextDecoration.lineThrough,
                          )
                        : style,
                    decoration: const InputDecoration(
                      hintText: AppStrings.listItemHint,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.delete,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
                  onPressed: () => editor.removeItem(id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddItemButton extends StatelessWidget {
  const _AddItemButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: () => context.read<NoteEditorController>().addItem(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.addListItem),
      ),
    );
  }
}
