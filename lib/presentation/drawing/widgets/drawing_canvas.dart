import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logic/drawing_controller.dart';

/// Touch surface + painter. Strokes repaint through the controller's
/// `canvasTick` listenable, so drawing never rebuilds a widget.
class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final DrawingController drawing = context.read<DrawingController>();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        drawing.canvasSize = constraints.biggest;
        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (DragStartDetails d) =>
                drawing.startStroke(d.localPosition),
            onPanUpdate: (DragUpdateDetails d) =>
                drawing.extendStroke(d.localPosition),
            onPanEnd: (_) => drawing.endStroke(),
            onPanCancel: drawing.endStroke,
            child: CustomPaint(
              size: constraints.biggest,
              isComplex: true,
              willChange: true,
              painter: _DrawingPainter(drawing),
            ),
          ),
        );
      },
    );
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter(this.controller) : super(repaint: controller.canvasTick);

  final DrawingController controller;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    controller.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter old) =>
      old.controller != controller;
}
