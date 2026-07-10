import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/surah_model.dart';

/// Surah metadata header on the reading screen.
class SurahHeader extends StatelessWidget {
  const SurahHeader({super.key, required this.surah});

  final SurahModel surah;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          Text(
            surah.name,
            style: AppTypography.arabic(
              fontSize: 28,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            surah.englishName,
            style: AppTypography.title(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${surah.englishNameTranslation} · ${surah.numberOfAyahs} Ayahs · ${surah.revelationType}',
            style: AppTypography.caption(context).copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (surah.number != 9) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: AppTypography.arabic(
                fontSize: 20,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],
        ],
      ),
    );
  }
}
