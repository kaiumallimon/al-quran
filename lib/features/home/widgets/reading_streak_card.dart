import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/dashboard_model.dart';

/// Reading streak display card.
class ReadingStreakCard extends StatelessWidget {
  const ReadingStreakCard({super.key, required this.streak});

  final StreakModel streak;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              Icons.local_fire_department_outlined,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reading Streak', style: AppTypography.caption(context)),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${streak.currentStreak}',
                      style: AppTypography.headline(context).copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      streak.currentStreak == 1 ? ' day' : ' days',
                      style: AppTypography.body(context).copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Best',
                style: AppTypography.small(context).copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '${streak.longestStreak}',
                style: AppTypography.subtitle(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
