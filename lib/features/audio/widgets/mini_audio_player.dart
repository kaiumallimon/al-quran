import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/audio_provider.dart';
import 'full_audio_player_sheet.dart';

/// Compact audio player shown above the bottom navigation bar.
class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        if (!audio.hasActiveTrack) return const SizedBox.shrink();

        final track = audio.currentTrack!;
        final colorScheme = Theme.of(context).colorScheme;

        return Material(
          elevation: 6,
          color: colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: audio.progress.clamp(0, 1),
                  minHeight: 2,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          audio.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: audio.togglePlayPause,
                        tooltip: audio.isPlaying ? 'Pause' : 'Play',
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => showFullAudioPlayerSheet(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  track.surahEnglishName,
                                  style: AppTypography.body(context).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Ayah ${track.numberInSurah}',
                                  style: AppTypography.small(context).copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (audio.isBuffering)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up),
                        onPressed: () => showFullAudioPlayerSheet(context),
                        tooltip: 'Expand player',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => audio.stop(),
                        tooltip: 'Stop',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
