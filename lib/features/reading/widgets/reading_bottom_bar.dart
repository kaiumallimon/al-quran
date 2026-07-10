import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/reading_provider.dart';

/// Placeholder bottom bar for audio controls (full player in audio feature).
class ReadingBottomBar extends StatelessWidget {
  const ReadingBottomBar({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<ReadingProvider>();
    final reciter = provider.preferences.preferredReciter;

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
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Audio player coming in next feature'),
                    ),
                  );
                },
                tooltip: 'Play surah',
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Surah $surahNumber',
                      style: AppTypography.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Reciter: $reciter',
                      style: AppTypography.small(context).copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.queue_music_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Queue — audio feature')),
                  );
                },
                tooltip: 'Queue',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
