import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/insight_model.dart';

/// Displays a single reading insight.
class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight});

  final InsightModel insight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              _iconFor(insight.icon),
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _categoryLabel(insight.category),
                  style: AppTypography.small(context).copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  insight.message,
                  style: AppTypography.body(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String icon) {
    switch (icon) {
      case 'schedule':
        return Icons.schedule_outlined;
      case 'calendar_today':
        return Icons.calendar_today_outlined;
      case 'timer':
        return Icons.timer_outlined;
      case 'local_fire_department':
        return Icons.local_fire_department_outlined;
      case 'check_circle':
        return Icons.check_circle_outline;
      case 'flag':
        return Icons.flag_outlined;
      case 'auto_stories':
        return Icons.auto_stories_outlined;
      case 'trending_up':
        return Icons.trending_up;
      case 'self_improvement':
        return Icons.self_improvement_outlined;
      case 'menu_book':
        return Icons.menu_book_outlined;
      default:
        return Icons.insights_outlined;
    }
  }

  String _categoryLabel(InsightCategory category) {
    switch (category) {
      case InsightCategory.daily:
        return 'Today';
      case InsightCategory.weekly:
        return 'This week';
      case InsightCategory.monthly:
        return 'This month';
      case InsightCategory.lifetime:
        return 'Overall';
    }
  }
}
