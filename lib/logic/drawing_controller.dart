import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/constants/constants.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';

/// A finished or in-progress brush stroke.
final class Stroke {
  Stroke(Offset start, this.paint)
    : path = Path()..moveTo(start.dx, start.dy),
      _last = start;

  final Path path;
  final Paint paint;
  Offset _last;
  bool _moved = false;

  /// Smooths the line by drawing quadratic curves through mid-points.
  void extend(Offset point) {
    final Offset mid = (_last + point) / 2;
    path.quadraticBezierTo(_last.dx, _last.dy, mid.dx, mid.dy);
    _last = point;
    _moved = true;
  }

  /// A tap without movement still leaves a dot.
  void close() {
    if (!_moved) path.lineTo(_last.dx + 0.01, _last.dy);
  }
}

/// Logic of the drawing canvas.
///
/// * Tool state (color, width, eraser, undo availability) → [notifyListeners].
/// * Canvas content → [canvasTick], consumed by `CustomPaint.repaint`, so
///   drawing repaints only the canvas and never rebuilds a widget.
/// * Completed strokes are baked into a cached [ui.Picture]; each frame only
///   replays that picture plus the active stroke.
final class DrawingController extends ChangeNotifier {
  DrawingController({required this.background});

  /// Canvas background (also used by the eraser).
  Color background;

  /// Latest laid-out canvas size (set by the canvas widget, used for export).
  Size canvasSize = Size.zero;

  final ValueNotifier<int> canvasTick = ValueNotifier<int>(0);
  final List<Stroke> _strokes = <Stroke>[];
  final List<Stroke> _redo = <Stroke>[];

  Stroke? _active;
  ui.Picture? _cache;

  Color _color = AppColors.brushColors.first;
  double _width = 4;
  bool _isEraser = false;

  static const double minWidth = 2;
  static const double maxWidth = 24;
  static const double _eraserFactor = 3;
  static const double _exportPixelRatio = 2;

  Color get color => _color;
  double get width => _width;
  bool get isEraser => _isEraser;
  bool get canUndo => _strokes.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  bool get isEmpty => _strokes.isEmpty && _active == null;

  void selectColor(Color color) {
    _color = color;
    _isEraser = false;
    notifyListeners();
  }

  void setWidth(double width) {
    _width = width.clamp(minWidth, maxWidth);
    notifyListeners();
  }

  void toggleEraser() {
    _isEraser = !_isEraser;
    notifyListeners();
  }

  // ───────────────────────── Gestures ─────────────────────────

  void startStroke(Offset point) {
    _active = Stroke(point, _buildPaint());
    _tick();
  }

  void extendStroke(Offset point) {
    final Stroke? stroke = _active;
    if (stroke == null) return;
    stroke.extend(point);
    _tick();
  }

  void endStroke() {
    final Stroke? stroke = _active;
    if (stroke == null) return;
    stroke.close();
    final bool couldUndo = canUndo, couldRedo = canRedo;
    _strokes.add(stroke);
    _redo.clear();
    _active = null;
    _rebuildCache();
    if (couldUndo != canUndo || couldRedo != canRedo) notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _redo.add(_strokes.removeLast());
    _rebuildCache();
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _strokes.add(_redo.removeLast());
    _rebuildCache();
    notifyListeners();
  }

  void clear() {
    if (_strokes.isEmpty) return;
    _strokes.clear();
    _redo.clear();
    _rebuildCache();
    notifyListeners();
  }

  // ───────────────────────── Rendering ─────────────────────────

  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final ui.Picture? cache = _cache;
    if (cache != null) canvas.drawPicture(cache);
    final Stroke? active = _active;
    if (active != null) canvas.drawPath(active.path, active.paint);
  }

  /// Renders the drawing to PNG bytes.
  Future<Uint8List> exportPng() {
    final Size size = canvasSize;
    return ErrorHandler.guard(
      () async {
        if (size.isEmpty) throw StateError('Canvas has no size');
        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(recorder)..scale(_exportPixelRatio);
        paint(canvas, size);
        final ui.Picture picture = recorder.endRecording();
        final ui.Image image = await picture.toImage(
          (size.width * _exportPixelRatio).round(),
          (size.height * _exportPixelRatio).round(),
        );
        try {
          final ByteData? data = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (data == null) throw StateError('PNG encoding returned null');
          return data.buffer.asUint8List();
        } finally {
          image.dispose();
          picture.dispose();
        }
      },
      (Object e, StackTrace s) =>
          MediaException(AppStrings.errorDrawing, cause: e, stackTrace: s),
    );
  }

  Paint _buildPaint() => Paint()
    ..color = _isEraser ? background : _color
    ..strokeWidth = _isEraser ? _width * _eraserFactor : _width
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  void _rebuildCache() {
    _cache?.dispose();
    if (_strokes.isEmpty) {
      _cache = null;
    } else {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      for (final Stroke stroke in _strokes) {
        canvas.drawPath(stroke.path, stroke.paint);
      }
      _cache = recorder.endRecording();
    }
    _tick();
  }

  void _tick() => canvasTick.value++;

  @override
  void dispose() {
    _cache?.dispose();
    canvasTick.dispose();
    super.dispose();
  }
}
