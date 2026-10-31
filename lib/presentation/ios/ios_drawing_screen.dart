import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_messenger.dart';
import '../../logic/drawing_controller.dart';
import '../drawing/widgets/drawing_canvas.dart';

class IosDrawingScreen extends StatelessWidget {
  const IosDrawingScreen({super.key});

  static Future<Uint8List?> open(BuildContext context) =>
      Navigator.of(context).push<Uint8List>(
        CupertinoPageRoute<Uint8List>(
          fullscreenDialog: true,
          builder: (_) => ChangeNotifierProvider<DrawingController>(
            create: (_) => DrawingController(background: CupertinoColors.white),
            child: const IosDrawingScreen(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      middle: const Text(AppStrings.drawingTitle),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.pop(context),
        child: const Text(AppStrings.cancel),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          final DrawingController drawing = context.read<DrawingController>();
          if (drawing.isEmpty) {
            AppMessenger.info(AppStrings.emptyDrawing);
            return;
          }
          try {
            final Uint8List png = await drawing.exportPng();
            if (context.mounted) Navigator.pop(context, png);
          } on Exception catch (error) {
            AppMessenger.error(error);
          }
        },
        child: const Text(AppStrings.saveDrawing),
      ),
    ),
    child: SafeArea(
      child: Column(
        children: <Widget>[
          const Expanded(child: DrawingCanvas()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CupertinoButton(
                onPressed: context.read<DrawingController>().undo,
                child: const Icon(CupertinoIcons.arrow_uturn_left),
              ),
              CupertinoButton(
                onPressed: context.read<DrawingController>().redo,
                child: const Icon(CupertinoIcons.arrow_uturn_right),
              ),
              for (final color in AppColors.brushColors.take(5))
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      context.read<DrawingController>().selectColor(color),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
