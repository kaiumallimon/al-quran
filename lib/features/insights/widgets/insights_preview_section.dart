import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/insights_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../providers/insights_provider.dart';
import 'insight_card.dart';
import 'recommendation_card.dart';

/// Compact insights preview for the home dashboard.
class InsightsPreviewSection extends StatelessWidget {
  const InsightsPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightsProvider>(
      builder: (context, provider, _) {
        if (provider.status == InsightsStatus.loading &&
            provider.insights.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SkeletonLoader(height: 24),
              SizedBox(height: AppSpacing.sm),
              SkeletonLoader(height: 72),
            ],
          );
        }

        if (provider.insights.isEmpty && provider.recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Insights',
              actionLabel: 'See all',
              action: () => InsightsNavigation.openInsights(context),
            ),
            if (provider.topRecommendation != null) ...[
              RecommendationCard(
                recommendation: provider.topRecommendation!,
                onTap: () => InsightsNavigation.handleRecommendation(
                  context,
                  provider.topRecommendation!,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            ...provider.recentInsights.take(2).map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: InsightCard(insight: insight),
                  ),
                ),
          ],
        );
      },
    );
  }
}
