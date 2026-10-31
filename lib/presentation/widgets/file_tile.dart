import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/attachment.dart';

/// Row describing a generic attached file (icon, name, size).
class FileTile extends StatelessWidget {
  const FileTile({
    super.key,
    required this.attachment,
    this.onTap,
    this.trailing,
    this.dense = false,
  });

  final Attachment attachment;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool dense;

  static IconData iconFor(String extension) => switch (extension) {
    'pdf' => Icons.picture_as_pdf_outlined,
    'doc' || 'docx' || 'txt' || 'rtf' || 'md' => Icons.description_outlined,
    'xls' || 'xlsx' || 'csv' => Icons.table_chart_outlined,
    'ppt' || 'pptx' => Icons.slideshow_outlined,
    'zip' || 'rar' || '7z' => Icons.folder_zip_outlined,
    'mp3' || 'm4a' || 'wav' || 'aac' || 'ogg' => Icons.audio_file_outlined,
    'mp4' || 'mov' || 'mkv' => Icons.video_file_outlined,
    _ => Icons.insert_drive_file_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final double iconBox = dense ? AppSizes.iconLg : AppSizes.iconXl - 8;
    return Material(
      color: context.colors.surfaceContainerLowest.withValues(
        alpha: context.isDark ? 0.08 : 0.7,
      ),
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(dense ? AppSpacing.sm : AppSpacing.md),
          child: Row(
            children: <Widget>[
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: palette.fileIconBackground,
                  borderRadius: AppRadius.baseAll,
                ),
                child: Icon(
                  iconFor(attachment.extension),
                  size: dense ? AppSizes.iconSm : AppSizes.icon,
                  color: palette.fileIconForeground,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      attachment.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: (dense
                          ? context.texts.labelMedium
                          : context.texts.titleSmall),
                    ),
                    Text(
                      '${attachment.extension.toUpperCase()} • ${Formatters.fileSize(attachment.sizeBytes)}',
                      style: context.texts.labelSmall?.copyWith(
                        color: context.colors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
