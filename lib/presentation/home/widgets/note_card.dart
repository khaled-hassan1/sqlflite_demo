import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/datasources/media_storage.dart';
import '../../../data/models/attachment.dart';
import '../../../data/models/note.dart';
import '../../utils/ui_actions.dart';
import '../../widgets/audio_player.dart';
import '../../widgets/file_tile.dart';
import 'card_checklist_preview.dart';
import 'card_footer.dart';
import 'card_media_header.dart';

/// Visual of a note in the masonry stream. Pure presentation: selection,
/// drop highlighting and gestures are supplied by `NoteGridItem`. Isolated in
/// its own [RepaintBoundary] so scrolling and neighbours don't repaint it.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    this.isSelected = false,
    this.isDropTarget = false,
    this.onTap,
    this.onLongPress,
  });

  final Note note;
  final bool isSelected;

  /// Another card is being dragged over this one.
  final bool isDropTarget;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static const int _maxAudios = 1;
  static const int _maxFiles = 2;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color background = note.color.container(brightness);
    final Color foreground = note.color.onContainer(brightness);
    final MediaStorage media = context.read<MediaStorage>();
    final List<Attachment> visuals = note.visuals.toList(growable: false);
    final bool hasBody =
        note.title.isNotEmpty || note.content.isNotEmpty || note.isChecklist;

    final ColorScheme colors = context.colors;
    final BorderSide side = isSelected
        ? BorderSide(color: colors.primary, width: 2.5)
        : isDropTarget
        ? BorderSide(color: colors.primary.withValues(alpha: 0.6), width: 2)
        : BorderSide(color: context.palette.cardBorder);

    return RepaintBoundary(
      child: Stack(
        children: <Widget>[
          // Material animates shape/border changes on its own.
          Material(
            color: background,
            animationDuration: AppDurations.fast,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll,
              side: side,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              child: DefaultTextStyle.merge(
                style: TextStyle(color: foreground),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (visuals.isNotEmpty)
                      CardMediaHeader(visuals: visuals, media: media),
                    Padding(
                      padding: AppInsets.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (note.isPinned) _PinMark(color: foreground),
                          if (note.title.isNotEmpty)
                            Text(
                              note.title,
                              maxLines: AppConfig.cardTitleMaxLines,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.titleMedium?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (note.isChecklist)
                            CardChecklistPreview(
                              items: note.checklist,
                              color: foreground,
                            )
                          else if (note.content.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: Text(
                                note.content,
                                maxLines: AppConfig.cardContentMaxLines,
                                overflow: TextOverflow.ellipsis,
                                style: context.texts.bodyMedium?.copyWith(
                                  color: foreground.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          for (final Attachment audio in note.audios.take(
                            _maxAudios,
                          ))
                            Padding(
                              padding: EdgeInsets.only(
                                top: hasBody ? AppSpacing.sm : 0,
                              ),
                              child: AudioPlayerChip(
                                attachment: audio,
                                path: media.pathOf(audio.fileName),
                                foreground: foreground,
                              ),
                            ),
                          for (final Attachment file in note.files.take(
                            _maxFiles,
                          ))
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.sm,
                              ),
                              child: FileTile(
                                attachment: file,
                                dense: true,
                                onTap: () => UiActions.openFile(
                                  media.pathOf(file.fileName),
                                ),
                              ),
                            ),
                          CardFooter(note: note, color: foreground),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: AppSpacing.xs,
            start: AppSpacing.xs,
            child: _SelectedMark(visible: isSelected),
          ),
        ],
      ),
    );
  }
}

/// Check badge that pops in when the card is selected.
class _SelectedMark extends StatelessWidget {
  const _SelectedMark({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    return IgnorePointer(
      child: AnimatedScale(
        scale: visible ? 1 : 0,
        duration: AppDurations.fast,
        curve: Curves.easeOutBack,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: colors.surface, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            child: Icon(
              Icons.check_rounded,
              size: AppSizes.iconSm,
              color: colors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PinMark extends StatelessWidget {
  const _PinMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Icon(
        Icons.push_pin_rounded,
        size: AppSizes.iconSm,
        color: color.withValues(alpha: 0.7),
      ),
    );
  }
}
