import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/audio_repeat_mode.dart';
import '../providers/audio_provider.dart';
import 'reciter_selection_sheet.dart';

/// Opens the expanded audio player bottom sheet.
void showFullAudioPlayerSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => const FullAudioPlayerSheet(),
  );
}

/// Expanded audio player with full playback controls.
class FullAudioPlayerSheet extends StatelessWidget {
  const FullAudioPlayerSheet({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        final track = audio.currentTrack;
        if (track == null) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No audio playing')),
          );
        }

        final colorScheme = Theme.of(context).colorScheme;
        final reciter = audio.currentReciter;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  track.surahEnglishName,
                  style: AppTypography.headline(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ayah ${track.numberInSurah}',
                  style: AppTypography.subtitle(context).copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: () => showReciterSelectionSheet(context),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          reciter?.name ?? track.reciterId,
                          style: AppTypography.small(context),
                        ),
                        const Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Slider(
                  value: audio.position.inMilliseconds.toDouble().clamp(
                        0,
                        (audio.duration?.inMilliseconds ?? 1).toDouble(),
                      ),
                  max: (audio.duration?.inMilliseconds ?? 1).toDouble(),
                  onChanged: (value) {
                    audio.seek(Duration(milliseconds: value.round()));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(audio.position),
                        style: AppTypography.small(context),
                      ),
                      Text(
                        _formatDuration(audio.duration ?? Duration.zero),
                        style: AppTypography.small(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: audio.skipToPrevious,
                      tooltip: 'Previous ayah',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilledButton(
                      onPressed: audio.togglePlayPause,
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                      ),
                      child: Icon(
                        audio.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.skip_next),
                      onPressed: audio.skipToNext,
                      tooltip: 'Next ayah',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _ControlChip(
                      icon: Icons.speed,
                      label: '${audio.preferences.playbackSpeed}x',
                      onTap: () => _showSpeedPicker(context, audio),
                    ),
                    _ControlChip(
                      icon: Icons.repeat,
                      label: audio.preferences.repeatMode.label,
                      onTap: () => _cycleRepeatMode(audio),
                    ),
                    _ControlChip(
                      icon: Icons.timer_outlined,
                      label: audio.preferences.sleepTimerMinutes > 0
                          ? '${audio.preferences.sleepTimerMinutes}m'
                          : 'Sleep',
                      onTap: () => _showSleepTimerPicker(context, audio),
                    ),
                    _ControlChip(
                      icon: Icons.download_outlined,
                      label: 'Save',
                      onTap: () async {
                        await audio.downloadCurrentSurah();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Surah audio saved for offline'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  void _cycleRepeatMode(AudioProvider audio) {
    final modes = AudioRepeatMode.values;
    final currentIndex = modes.indexOf(audio.preferences.repeatMode);
    final next = modes[(currentIndex + 1) % modes.length];
    audio.setRepeatMode(next);
  }

  void _showSpeedPicker(BuildContext context, AudioProvider audio) {
    const speeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds
              .map(
                (speed) => ListTile(
                  title: Text('${speed}x'),
                  trailing: audio.preferences.playbackSpeed == speed
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    audio.setSpeed(speed);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showSleepTimerPicker(BuildContext context, AudioProvider audio) {
    const options = [0, 5, 10, 15, 30, 45, 60];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (minutes) => ListTile(
                  title: Text(minutes == 0 ? 'Off' : '$minutes minutes'),
                  trailing: audio.preferences.sleepTimerMinutes == minutes
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    audio.startSleepTimer(minutes);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
