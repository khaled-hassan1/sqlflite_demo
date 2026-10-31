import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/notes_overview.dart';
import '../../../logic/notes_provider.dart';
import 'drawer_group.dart';

/// Local storage usage breakdown + backup / restore.
class StorageCard extends StatelessWidget {
  const StorageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerGroup(
      padding: AppInsets.allLg,
      children: <Widget>[
        Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: context.palette.accent,
              child: Icon(
                Icons.storage_rounded,
                color: context.palette.onAccent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppStrings.localStorage,
                    style: context.texts.titleSmall,
                  ),
                  Text(
                    AppStrings.localStorageSubtitle,
                    style: context.texts.labelSmall?.copyWith(
                      color: context.colors.outline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.verified_user_outlined, color: context.colors.primary),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _UsageBreakdown(),
        const SizedBox(height: AppSpacing.lg),
        const _BackupButtons(),
      ],
    );
  }
}

class _UsageBreakdown extends StatelessWidget {
  const _UsageBreakdown();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Selector<NotesProvider, StorageUsage>(
      selector: (_, NotesProvider p) => p.usage,
      builder: (BuildContext context, StorageUsage usage, _) {
        final int total = usage.total == 0 ? 1 : usage.total;
        int flex(int bytes) => bytes == 0 ? 0 : (bytes * 1000 / total).ceil();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    AppStrings.usedSpace,
                    style: context.texts.labelMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  Formatters.fileSize(usage.total),
                  style: context.texts.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.fullAll,
              child: SizedBox(
                height: AppSizes.storageBarHeight,
                child: usage.total == 0
                    ? ColoredBox(color: context.colors.surfaceContainerHighest)
                    : Row(
                        children: <Widget>[
                          if (usage.audioBytes > 0)
                            Expanded(
                              flex: flex(usage.audioBytes),
                              child: ColoredBox(color: palette.storageAudio),
                            ),
                          if (usage.imageBytes > 0)
                            Expanded(
                              flex: flex(usage.imageBytes),
                              child: ColoredBox(color: palette.storageImages),
                            ),
                          if (usage.textBytes > 0)
                            Expanded(
                              flex: flex(usage.textBytes),
                              child: ColoredBox(color: palette.storageText),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                _UsageTile(
                  icon: Icons.audio_file_outlined,
                  label: AppStrings.storageAudio,
                  bytes: usage.audioBytes,
                  color: palette.storageAudio,
                ),
                const SizedBox(width: AppSpacing.sm),
                _UsageTile(
                  icon: Icons.image_outlined,
                  label: AppStrings.storageImages,
                  bytes: usage.imageBytes,
                  color: palette.storageImages,
                ),
                const SizedBox(width: AppSpacing.sm),
                _UsageTile(
                  icon: Icons.article_outlined,
                  label: AppStrings.storageText,
                  bytes: usage.textBytes,
                  color: palette.storageText,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _UsageTile extends StatelessWidget {
  const _UsageTile({
    required this.icon,
    required this.label,
    required this.bytes,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int bytes;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLowest,
          borderRadius: AppRadius.mdAll,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: AppSizes.iconXs, color: color),
                  const SizedBox(width: AppSpacing.xxs),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.labelSmall?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                Formatters.megaBytes(bytes),
                textDirection: TextDirection.ltr,
                style: context.texts.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackupButtons extends StatelessWidget {
  const _BackupButtons();

  @override
  Widget build(BuildContext context) {
    final NotesProvider notes = context.read<NotesProvider>();
    return ValueListenableBuilder<bool>(
      valueListenable: notes.isBusy,
      builder: (BuildContext context, bool busy, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FilledButton.icon(
            onPressed: busy ? null : notes.exportBackup,
            icon: busy
                ? const SizedBox.square(
                    dimension: AppSizes.iconSm,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded),
            label: const Text(AppStrings.backup),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: busy ? null : notes.importBackup,
            icon: const Icon(Icons.upload_rounded),
            label: const Text(AppStrings.restore),
          ),
        ],
      ),
    );
  }
}
