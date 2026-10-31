import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/attachment.dart';
import '../../logic/audio_playback_provider.dart';
import 'waveform.dart';

/// Full audio player used inside the note editor.
class AudioPlayerCard extends StatelessWidget {
  const AudioPlayerCard({
    super.key,
    required this.attachment,
    required this.path,
    this.onDelete,
  });

  final Attachment attachment;

  /// Absolute path of the audio file.
  final String path;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    return RepaintBoundary(
      child: Material(
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
          side: BorderSide(color: context.palette.cardBorder),
        ),
        child: Padding(
          padding: AppInsets.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(attachment: attachment, onDelete: onDelete),
              const SizedBox(height: AppSpacing.md),
              _SeekableWaveform(
                path: path,
                seed: attachment.id,
                height: AppSizes.waveformHeight,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  _SkipButton(path: path, forward: false),
                  const SizedBox(width: AppSpacing.sm),
                  PlayPauseButton(path: path, size: AppSizes.playButtonLarge),
                  const SizedBox(width: AppSpacing.sm),
                  _SkipButton(path: path, forward: true),
                  const Spacer(),
                  _TimeLabel(path: path, total: attachment.duration),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact player shown inside note cards.
class AudioPlayerChip extends StatelessWidget {
  const AudioPlayerChip({
    super.key,
    required this.attachment,
    required this.path,
    required this.foreground,
  });

  final Attachment attachment;
  final String path;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerLowest.withValues(
        alpha: context.isDark ? 0.12 : 0.7,
      ),
      borderRadius: AppRadius.lgAll,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: <Widget>[
            PlayPauseButton(path: path, size: AppSizes.playButton - 8),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SeekableWaveform(
                path: path,
                seed: attachment.id,
                height: AppSizes.waveformHeightSmall,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              Formatters.duration(attachment.duration),
              style: context.texts.labelMedium?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.attachment, this.onDelete});

  final Attachment attachment;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: AppSizes.icon * 0.75,
          backgroundColor: palette.accent,
          child: Icon(
            Icons.mic_rounded,
            size: AppSizes.iconSm,
            color: palette.onAccent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                attachment.displayName,
                style: context.texts.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${Formatters.fileSize(attachment.sizeBytes)} • ${Formatters.duration(attachment.duration)}',
                style: context.texts.labelSmall?.copyWith(
                  color: context.colors.outline,
                ),
              ),
            ],
          ),
        ),
        const _SpeedButton(),
        if (onDelete != null)
          IconButton(
            tooltip: AppStrings.delete,
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded),
          ),
      ],
    );
  }
}

/// Play/pause toggle bound to one file; rebuilds only when *its* state flips.
class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, required this.path, required this.size});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    return Selector<AudioPlaybackProvider, bool>(
      selector: (_, AudioPlaybackProvider p) => p.isPlayingPath(path),
      builder: (BuildContext context, bool isPlaying, _) => SizedBox.square(
        dimension: size,
        child: IconButton.filled(
          tooltip: isPlaying ? AppStrings.pause : AppStrings.play,
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          onPressed: () => context.read<AudioPlaybackProvider>().toggle(path),
          icon: AnimatedSwitcher(
            duration: AppDurations.fast,
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey<bool>(isPlaying),
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );
  }
}

class _SeekableWaveform extends StatelessWidget {
  const _SeekableWaveform({
    required this.path,
    required this.seed,
    required this.height,
  });

  final String path;
  final String seed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Selector<AudioPlaybackProvider, bool>(
      selector: (_, AudioPlaybackProvider p) => p.isCurrent(path),
      builder: (BuildContext context, bool isCurrent, _) {
        final AudioPlaybackProvider playback = context
            .read<AudioPlaybackProvider>();
        final Widget wave = Waveform(
          levels: Waveform.seeded(seed),
          height: height,
          progress: isCurrent
              ? DurationFraction(playback.position, playback.duration)
              : _zero,
          activeColor: palette.waveActive,
          inactiveColor: palette.waveInactive,
          highlightColor: palette.waveHighlight,
        );
        if (!isCurrent) return wave;
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (TapDownDetails d) {
                  final double x = d.localPosition.dx / constraints.maxWidth;
                  final bool rtl =
                      Directionality.of(context) == TextDirection.rtl;
                  playback.seekFraction(rtl ? 1 - x : x);
                },
                child: wave,
              ),
        );
      },
    );
  }

  static final ValueNotifier<double> _zero = ValueNotifier<double>(0);
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.path, required this.total});

  final String path;
  final Duration total;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = context.texts.titleSmall?.copyWith(
      color: context.colors.primary,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    final String totalText = Formatters.duration(total);
    return Selector<AudioPlaybackProvider, bool>(
      selector: (_, AudioPlaybackProvider p) => p.isCurrent(path),
      builder: (BuildContext context, bool isCurrent, _) {
        if (!isCurrent) {
          return Text(
            '${Formatters.duration(Duration.zero)} / $totalText',
            style: style,
          );
        }
        return ValueListenableBuilder<Duration>(
          valueListenable: context.read<AudioPlaybackProvider>().position,
          builder: (BuildContext context, Duration position, _) => Text(
            '${Formatters.duration(position)} / $totalText',
            style: style,
          ),
        );
      },
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.path, required this.forward});

  final String path;
  final bool forward;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final AudioPlaybackProvider playback = context
            .read<AudioPlaybackProvider>();
        if (playback.isCurrent(path)) {
          playback.seekBy(
            forward ? AppDurations.seekStep : -AppDurations.seekStep,
          );
        }
      },
      icon: Icon(forward ? Icons.forward_5_rounded : Icons.replay_5_rounded),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton();

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlaybackProvider, double>(
      selector: (_, AudioPlaybackProvider p) => p.speed,
      builder: (BuildContext context, double speed, _) => ActionChip(
        tooltip: AppStrings.speed,
        label: Text(
          '${speed == speed.roundToDouble() ? speed.toInt() : speed}x',
        ),
        onPressed: context.read<AudioPlaybackProvider>().cycleSpeed,
      ),
    );
  }
}
