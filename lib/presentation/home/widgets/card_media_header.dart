import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/datasources/media_storage.dart';
import '../../../data/models/attachment.dart';
import '../../widgets/local_image.dart';

/// First image/drawing of a note, flush with the card's top corners, plus a
/// "+N" badge when there are more.
class CardMediaHeader extends StatelessWidget {
  const CardMediaHeader({
    super.key,
    required this.visuals,
    required this.media,
  });

  final List<Attachment> visuals;
  final MediaStorage media;

  @override
  Widget build(BuildContext context) {
    final Attachment first = visuals.first;
    final int extra = visuals.length - 1;
    return SizedBox(
      height: AppSizes.cardImageMaxHeight * 0.8,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          LocalImage(path: media.pathOf(first.fileName)),
          if (extra > 0)
            PositionedDirectional(
              bottom: AppSpacing.sm,
              end: AppSpacing.sm,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.imageOverlay,
                  borderRadius: AppRadius.lgAll,
                ),
                child: Padding(
                  padding: AppInsets.chip,
                  child: Text(
                    '+${Formatters.number(extra)}',
                    style: context.texts.labelMedium?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
