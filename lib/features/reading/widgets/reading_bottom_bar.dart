import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/reciter_model.dart';
import '../../audio/providers/audio_provider.dart';
import '../../audio/widgets/full_audio_player_sheet.dart';
import '../providers/reading_provider.dart';

/// Bottom bar for audio controls on the reading screen.
class ReadingBottomBar extends StatelessWidget {
  const ReadingBottomBar({
    super.key,
    required this.surahNumber,
    this.surahEnglishName,
  });

  final int surahNumber;
  final String? surahEnglishName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reading = context.watch<ReadingProvider>();
    final audio = context.watch<AudioProvider>();
    final reciter = ReciterModel.findById(reading.preferences.preferredReciter);
    final isCurrentSurah = audio.currentTrack?.surahNumber == surahNumber;
    final isPlaying = isCurrentSurah && audio.isPlaying;

    return Material(
      elevation: 4,
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              IconButton.filledTonal(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () async {
                  if (isCurrentSurah) {
                    await audio.togglePlayPause();
                    return;
                  }

                  await audio.playSurah(
                    surahNumber,
                    startAyah: reading.highlightedAyah ?? 1,
                  );
                  await reading.updatePreferences(
                    reading.preferences.copyWith(
                      preferredReciter: audio.preferences.preferredReciter,
                    ),
                  );
                },
                tooltip: isPlaying ? 'Pause' : 'Play surah',
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (audio.hasActiveTrack) {
                      showFullAudioPlayerSheet(context);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        surahEnglishName ?? 'Surah $surahNumber',
                        style: AppTypography.body(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isCurrentSurah && audio.currentTrack != null
                            ? 'Ayah ${audio.currentTrack!.numberInSurah} · ${reciter?.name ?? reading.preferences.preferredReciter}'
                            : 'Reciter: ${reciter?.name ?? reading.preferences.preferredReciter}',
                        style: AppTypography.small(context).copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (isCurrentSurah)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: audio.progress.clamp(0, 1),
                    strokeWidth: 3,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.open_in_full),
                onPressed: () {
                  if (audio.hasActiveTrack) {
                    showFullAudioPlayerSheet(context);
                  }
                },
                tooltip: 'Expand player',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
