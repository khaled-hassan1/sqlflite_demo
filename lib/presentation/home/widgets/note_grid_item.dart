import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../data/models/note.dart';
import '../../../logic/notes_provider.dart';
import '../../editor/note_editor_screen.dart';
import '../../widgets/appear_animation.dart';
import 'note_actions_sheet.dart';
import 'note_card.dart';

/// Interactive wrapper around [NoteCard]:
/// * long-press lifts the card: drop it on another card to reorder, or
///   release in place to select it (multi-select);
/// * while selecting, taps toggle selection instead of opening the note.
class NoteGridItem extends StatelessWidget {
  const NoteGridItem({super.key, required this.note, required this.canReorder});

  final Note note;

  /// Trash is not user-ordered, so dragging is disabled there.
  final bool canReorder;

  static const double _liftScale = 1.03;
  static const double _draggingOpacity = 0.3;
  static const double _autoScrollEdge = 96;
  static const double _autoScrollStep = 14;

  void _onTap(BuildContext context, bool isSelecting) {
    final NotesProvider notes = context.read<NotesProvider>();
    if (isSelecting) {
      notes.toggleSelection(note.id);
    } else if (note.isTrashed) {
      NoteActionsSheet.show(context, note.id);
    } else {
      NoteEditorScreen.open(context, note: note);
    }
  }

  void _onLongPress(BuildContext context) {
    HapticFeedback.selectionClick();
    context.read<NotesProvider>().toggleSelection(note.id);
  }

  @override
  Widget build(BuildContext context) {
    return AppearAnimation(
      child: Selector<NotesProvider, (bool, bool)>(
        selector: (_, NotesProvider p) =>
            (p.isSelected(note.id), p.isSelecting),
        builder: (BuildContext context, (bool, bool) state, _) {
          final (bool isSelected, bool isSelecting) = state;
          if (!canReorder) {
            return NoteCard(
              note: note,
              isSelected: isSelected,
              onTap: () => _onTap(context, isSelecting),
              onLongPress: () => _onLongPress(context),
            );
          }
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                _buildDraggable(
                  context,
                  constraints.maxWidth,
                  isSelected,
                  isSelecting,
                ),
          );
        },
      ),
    );
  }

  Widget _buildDraggable(
    BuildContext context,
    double width,
    bool isSelected,
    bool isSelecting,
  ) {
    final NotesProvider notes = context.read<NotesProvider>();
    final Widget target = DragTarget<String>(
      onWillAcceptWithDetails: (DragTargetDetails<String> d) =>
          notes.canMove(d.data, note.id),
      onAcceptWithDetails: (DragTargetDetails<String> d) {
        HapticFeedback.lightImpact();
        notes.moveNote(d.data, note.id);
      },
      builder: (BuildContext context, List<String?> candidates, _) => NoteCard(
        note: note,
        isSelected: isSelected,
        isDropTarget: candidates.isNotEmpty,
        onTap: () => _onTap(context, isSelecting),
      ),
    );

    return LongPressDraggable<String>(
      data: note.id,
      hapticFeedbackOnStart: true,
      // Selecting on lift mirrors Google Keep: a long-press without a drop
      // leaves the note selected.
      onDragStarted: () {
        if (!notes.isSelected(note.id)) notes.toggleSelection(note.id);
      },
      // A completed move is not a selection gesture.
      onDragCompleted: () {
        if (notes.selectedIds.length == 1 && notes.isSelected(note.id)) {
          notes.clearSelection();
        }
      },
      onDragUpdate: (DragUpdateDetails d) =>
          _autoScroll(context, d.globalPosition),
      feedback: SizedBox(
        width: width,
        child: Transform.scale(
          scale: _liftScale,
          child: Material(
            type: MaterialType.transparency,
            elevation: 8,
            borderRadius: AppRadius.mdAll,
            child: NoteCard(note: note),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: _draggingOpacity, child: target),
      child: target,
    );
  }

  /// Scrolls the grid when a dragged card nears the top/bottom edge.
  static void _autoScroll(BuildContext context, Offset global) {
    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;
    final ScrollPosition position = scrollable.position;
    final double height = MediaQuery.sizeOf(context).height;
    double delta = 0;
    if (global.dy < _autoScrollEdge) {
      delta = -_autoScrollStep;
    } else if (global.dy > height - _autoScrollEdge) {
      delta = _autoScrollStep;
    }
    if (delta == 0) return;
    position.jumpTo(
      math.min(
        position.maxScrollExtent,
        math.max(position.minScrollExtent, position.pixels + delta),
      ),
    );
  }
}
