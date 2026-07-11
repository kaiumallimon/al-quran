import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/daily_verse_model.dart';

/// Daily verse card with Arabic, translation, and actions.
class DailyVerseCard extends StatelessWidget {
  const DailyVerseCard({
    super.key,
    required this.verse,
    this.onPlayAudio,
  });

  final DailyVerseModel verse;
  final VoidCallback? onPlayAudio;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ayah = verse.ayah;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined,
                  color: colorScheme.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Daily Verse',
                style: AppTypography.caption(context).copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                verse.reference,
                style: AppTypography.small(context).copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            ayah.text,
            style: AppTypography.arabic(
              fontSize: 24,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          if (ayah.englishText != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              ayah.englishText!,
              style: AppTypography.body(context).copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.6,
              ),
            ),
          ],
          if (ayah.banglaTransliteration != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              ayah.banglaTransliteration!,
              style: AppTypography.bangla(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${verse.englishName} · Ayah ${ayah.numberInSurah}',
            style: AppTypography.small(context).copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {},
                tooltip: 'Bookmark',
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _shareVerse(verse),
                tooltip: 'Share',
              ),
              if (onPlayAudio != null)
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  onPressed: onPlayAudio,
                  tooltip: 'Play audio',
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareVerse(DailyVerseModel verse) {
    final ayah = verse.ayah;
    final text = StringBuffer()
      ..writeln(ayah.text)
      ..writeln()
      ..writeln(ayah.englishText ?? '')
      ..writeln()
      ..writeln('— ${verse.englishName} ${verse.reference}');

    SharePlus.instance.share(
        ShareParams(downloadFallbackEnabled: true, text: text.toString()));
  }
}

/// Placeholder when daily verse is loading.
class DailyVersePlaceholder extends StatelessWidget {
  const DailyVersePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text('Daily Verse', style: AppTypography.subtitle(context)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: AppTypography.arabic(fontSize: 24),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Loading today\'s verse...',
            style: AppTypography.caption(context).copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
