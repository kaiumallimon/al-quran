import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/reading_summary_model.dart';

/// Summary statistics card for a reading period.
class ReadingSummaryCard extends StatelessWidget {
  const ReadingSummaryCard({
    super.key,
    required this.title,
    required this.summary,
  });

  final String title;
  final ReadingSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subtitle(context)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Stat(
                label: 'Minutes',
                value: '${summary.readingMinutes}',
              ),
              _Stat(
                label: 'Ayahs',
                value: '${summary.ayahsRead}',
              ),
              _Stat(
                label: 'Sessions',
                value: '${summary.sessions}',
              ),
              _Stat(
                label: 'Active days',
                value: '${summary.activeDays}',
              ),
            ],
          ),
          if (summary.averageSessionMinutes > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Avg session: ${summary.averageSessionMinutes} min',
              style: AppTypography.caption(context),
            ),
          ],
          if (summary.mostReadSurahName != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Most read: ${summary.mostReadSurahName}',
              style: AppTypography.caption(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.title(context).copyWith(fontSize: 20),
          ),
          Text(
            label,
            style: AppTypography.small(context).copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
