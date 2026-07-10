import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/dashboard_model.dart';

/// Today's reading statistics card.
class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({super.key, required this.progress});

  final TodayProgressModel progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Progress", style: AppTypography.subtitle(context)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _StatItem(
                icon: Icons.timer_outlined,
                value: '${progress.readingMinutes}',
                label: 'minutes',
              ),
              _StatItem(
                icon: Icons.auto_stories_outlined,
                value: '${progress.pagesRead}',
                label: 'pages',
              ),
              _StatItem(
                icon: Icons.format_list_numbered,
                value: '${progress.ayahsRead}',
                label: 'ayahs',
              ),
              _StatItem(
                icon: Icons.repeat,
                value: '${progress.sessions}',
                label: 'sessions',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.title(context).copyWith(fontSize: 20),
          ),
          Text(
            label,
            style: AppTypography.small(context).copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
