import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../logic/drawing_controller.dart';

/// Brush colors, eraser toggle and stroke width.
class DrawingToolbar extends StatelessWidget {
  const DrawingToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerLow,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[_ColorsRow(), _WidthRow()],
        ),
      ),
    );
  }
}

class _ColorsRow extends StatelessWidget {
  const _ColorsRow();

  @override
  Widget build(BuildContext context) {
    final DrawingController drawing = context.read<DrawingController>();
    return Selector<DrawingController, (Color, bool)>(
      selector: (_, DrawingController d) => (d.color, d.isEraser),
      builder: (BuildContext context, (Color, bool) state, _) {
        final (Color selected, bool isEraser) = state;
        return SizedBox(
          height: AppSizes.colorDot + AppSpacing.sm,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: AppInsets.screen,
            children: <Widget>[
              IconButton(
                tooltip: AppStrings.eraser,
                isSelected: isEraser,
                onPressed: drawing.toggleEraser,
                icon: const Icon(Icons.auto_fix_normal_outlined),
                selectedIcon: const Icon(Icons.auto_fix_normal),
              ),
              for (final Color color in AppColors.brushColors)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.sm,
                  ),
                  child: InkResponse(
                    onTap: () => drawing.selectColor(color),
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      width: AppSizes.colorDot,
                      height: AppSizes.colorDot,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: !isEraser && color == selected
                              ? context.colors.primary
                              : context.colors.outlineVariant,
                          width: !isEraser && color == selected ? 3 : 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _WidthRow extends StatelessWidget {
  const _WidthRow();

  @override
  Widget build(BuildContext context) {
    final DrawingController drawing = context.read<DrawingController>();
    return Padding(
      padding: AppInsets.screen,
      child: Row(
        children: <Widget>[
          const Icon(Icons.line_weight_rounded),
          Expanded(
            child: Selector<DrawingController, double>(
              selector: (_, DrawingController d) => d.width,
              builder: (BuildContext context, double width, _) => Slider(
                value: width,
                min: DrawingController.minWidth,
                max: DrawingController.maxWidth,
                label: AppStrings.strokeWidth,
                onChanged: drawing.setWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
