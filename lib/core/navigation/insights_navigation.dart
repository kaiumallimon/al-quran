import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/recommendation_model.dart';
import '../../features/home/providers/dashboard_provider.dart';
import '../../features/insights/pages/insights_page.dart';
import 'reading_navigation.dart';
import 'tracking_navigation.dart';

/// Navigation helpers for insights and recommendations.
class InsightsNavigation {
  InsightsNavigation._();

  static void openInsights(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const InsightsPage(),
      ),
    );
  }

  static void handleRecommendation(
    BuildContext context,
    RecommendationModel recommendation,
  ) {
    switch (recommendation.action) {
      case RecommendationAction.continueReading:
        final dashboard = context.read<DashboardProvider>();
        final progress = dashboard.continueReading;
        if (progress != null) {
          ReadingNavigation.openSurah(
            context,
            surahNumber: progress.surahNumber,
            initialAyah: progress.ayahNumber,
          );
        } else if (recommendation.surahNumber != null) {
          ReadingNavigation.openSurah(
            context,
            surahNumber: recommendation.surahNumber!,
            initialAyah: recommendation.ayahNumber ?? 1,
          );
        }
      case RecommendationAction.completeGoal:
      case RecommendationAction.maintainStreak:
        final progress = context.read<DashboardProvider>().continueReading;
        if (progress != null) {
          ReadingNavigation.openSurah(
            context,
            surahNumber: progress.surahNumber,
            initialAyah: progress.ayahNumber,
          );
        } else {
          ReadingNavigation.openSurah(context, surahNumber: 1);
        }
      case RecommendationAction.openSurah:
        if (recommendation.surahNumber != null) {
          ReadingNavigation.openSurah(
            context,
            surahNumber: recommendation.surahNumber!,
            initialAyah: recommendation.ayahNumber ?? 1,
          );
        }
      case RecommendationAction.openGoals:
        TrackingNavigation.openHub(context, initialTab: 3);
      case RecommendationAction.openInsights:
        openInsights(context);
    }
  }
}
