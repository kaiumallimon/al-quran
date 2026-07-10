import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/dashboard_model.dart';

/// Daily reading goal progress card.
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key, required this.goal});

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = goal.progressPercent;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_outlined, color: colorScheme.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Daily Goal',
                style: AppTypography.caption(context).copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${goal.completedAyahs}',
                style: AppTypography.headline(context).copyWith(
                  color: colorScheme.primary,
                ),
              ),
              Text(
                ' / ${goal.targetAyahs} ayahs',
                style: AppTypography.body(context).copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              Text(
                '${(percent * 100).toInt()}%',
                style: AppTypography.subtitle(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                  minHeight: 8,
                ),
              );
            },
          ),
          if (goal.remainingAyahs > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${goal.remainingAyahs} ayahs remaining today',
              style: AppTypography.small(context).copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Goal completed! MashaAllah',
              style: AppTypography.small(context).copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
