import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/reading_summary_model.dart';

/// Simple bar chart showing daily reading activity.
class ReadingActivityChart extends StatelessWidget {
  const ReadingActivityChart({
    super.key,
    required this.activity,
    this.maxBars = 7,
  });

  final List<DailyActivityModel> activity;
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bars = activity.take(maxBars).toList();
    if (bars.isEmpty) return const SizedBox.shrink();

    final maxAyahs = bars
        .map((d) => d.ayahsRead)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reading activity', style: AppTypography.subtitle(context)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((day) {
                final heightFactor =
                    maxAyahs > 0 ? day.ayahsRead / maxAyahs : 0.0;
                final barHeight = (heightFactor * 72).clamp(4.0, 72.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: day.ayahsRead > 0
                                ? colorScheme.primary.withValues(alpha: 0.7)
                                : colorScheme.onSurface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _dayLabel(day.date),
                          style: AppTypography.small(context).copyWith(
                            fontSize: 10,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime date) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[date.weekday - 1];
  }
}
