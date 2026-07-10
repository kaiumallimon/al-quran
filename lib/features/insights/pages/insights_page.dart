import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/insights_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../providers/insights_provider.dart';
import '../widgets/insight_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/reading_activity_chart.dart';
import '../widgets/reading_summary_card.dart';

/// Full insights and recommendations screen.
class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsProvider>().loadInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: Consumer<InsightsProvider>(
        builder: (context, provider, _) {
          if (provider.status == InsightsStatus.loading &&
              provider.insights.isEmpty) {
            return _buildLoading();
          }

          if (provider.status == InsightsStatus.error &&
              provider.insights.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ErrorStateWidget(
                  message: provider.errorMessage ?? 'Something went wrong',
                  onRetry: provider.loadInsights,
                ),
              ),
            );
          }

          if (provider.insights.isEmpty &&
              provider.recommendations.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.insights_outlined,
              title: 'No insights yet',
              subtitle:
                  'Keep reading and your habits will appear here with gentle suggestions.',
              actionLabel: 'Start reading',
              onAction: () => Navigator.of(context).pop(),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: _buildContent(provider),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(height: 120),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(height: 80),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(height: 80),
      ],
    );
  }

  Widget _buildContent(InsightsProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (provider.recommendations.isNotEmpty) ...[
          const SectionHeader(title: 'For you'),
          ...provider.recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: RecommendationCard(
                recommendation: rec,
                onTap: () =>
                    InsightsNavigation.handleRecommendation(context, rec),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        ReadingSummaryCard(
          title: 'This week',
          summary: provider.weeklySummary,
        ),
        const SizedBox(height: AppSpacing.md),
        ReadingActivityChart(activity: provider.weeklyActivity),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Reading insights'),
        if (provider.insights.isEmpty)
          Text(
            'Read a little more to unlock personalized insights.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          ...provider.insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InsightCard(insight: insight),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        ReadingSummaryCard(
          title: 'This month',
          summary: provider.monthlySummary,
        ),
        const SizedBox(height: AppSpacing.md),
        ReadingSummaryCard(
          title: 'Lifetime',
          summary: provider.lifetimeSummary,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
