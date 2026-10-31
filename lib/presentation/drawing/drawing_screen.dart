import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/app_messenger.dart';
import '../../logic/drawing_controller.dart';
import 'widgets/drawing_canvas.dart';
import 'widgets/drawing_toolbar.dart';

/// Free-hand drawing. Pops with PNG bytes, or `null` when cancelled.
class DrawingScreen extends StatelessWidget {
  const DrawingScreen({super.key});

  static Future<Uint8List?> open(BuildContext context) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(
        fullscreenDialog: true,
        builder: (BuildContext context) =>
            ChangeNotifierProvider<DrawingController>(
              create: (_) =>
                  DrawingController(background: context.palette.canvas),
              child: const DrawingScreen(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.canvas,
      appBar: AppBar(
        backgroundColor: context.palette.canvas,
        title: const Text(AppStrings.drawingTitle),
        actions: const <Widget>[_HistoryButtons(), _SaveButton()],
      ),
      body: const SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: DrawingCanvas()),
            DrawingToolbar(),
          ],
        ),
      ),
    );
  }
}

class _HistoryButtons extends StatelessWidget {
  const _HistoryButtons();

  @override
  Widget build(BuildContext context) {
    final DrawingController drawing = context.read<DrawingController>();
    return Selector<DrawingController, (bool, bool)>(
      selector: (_, DrawingController d) => (d.canUndo, d.canRedo),
      builder: (BuildContext context, (bool, bool) state, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: AppStrings.undoStroke,
            onPressed: state.$1 ? drawing.undo : null,
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            tooltip: AppStrings.redoStroke,
            onPressed: state.$2 ? drawing.redo : null,
            icon: const Icon(Icons.redo_rounded),
          ),
          IconButton(
            tooltip: AppStrings.clearCanvas,
            onPressed: state.$1 ? drawing.clear : null,
            icon: const Icon(Icons.layers_clear_outlined),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppStrings.saveDrawing,
      icon: const Icon(Icons.check_rounded),
      onPressed: () async {
        final DrawingController drawing = context.read<DrawingController>();
        final NavigatorState navigator = Navigator.of(context);
        if (drawing.isEmpty) {
          AppMessenger.info(AppStrings.emptyDrawing);
          return;
        }
        try {
          navigator.pop(await drawing.exportPng());
        } on Exception catch (error) {
          AppMessenger.error(error);
        }
      },
    );
  }
}
