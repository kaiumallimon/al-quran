import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/notification_navigation.dart';
import '../../../core/navigation/insights_navigation.dart';
import '../../../core/navigation/reading_navigation.dart';
import '../../../core/navigation/tracking_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shell/providers/app_shell_provider.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../providers/dashboard_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../insights/providers/insights_provider.dart';
import '../../insights/widgets/insights_preview_section.dart';
import '../widgets/continue_reading_card.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/daily_verse_card.dart';
import '../widgets/dashboard_greeting.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/reading_streak_card.dart';
import '../widgets/recently_read_section.dart';
import '../widgets/today_progress_card.dart';

/// Primary home dashboard screen.
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
      context.read<InsightsProvider>().loadInsights();
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              return IconButton(
                tooltip: 'Notifications',
                onPressed: () => NotificationNavigation.openNotifications(context),
                icon: Badge(
                  isLabelVisible: provider.unreadCount > 0,
                  label: Text(
                    provider.unreadCount > 9
                        ? '9+'
                        : '${provider.unreadCount}',
                  ),
                  child: const Icon(Icons.notifications_outlined),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.status == DashboardStatus.loading &&
              provider.dashboard == null) {
            return _buildLoadingSkeleton();
          }

          if (provider.status == DashboardStatus.error &&
              provider.dashboard == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ErrorStateWidget(
                  message: provider.errorMessage ?? 'Something went wrong',
                  onRetry: provider.loadDashboard,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.refresh();
              if (!context.mounted) return;
              await context.read<InsightsProvider>().refresh();
              if (!context.mounted) return;
              await context.read<NotificationProvider>().refresh();
            },
            child: _buildContent(provider),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(height: 60),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(height: 160),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(height: 120),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(height: 100),
      ],
    );
  }

  Widget _buildContent(DashboardProvider provider) {
    final maxWidth = AppConstants.expandedBreakpoint;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth > maxWidth
            ? maxWidth
            : constraints.maxWidth;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DashboardGreeting(),
                    const SizedBox(height: AppSpacing.lg),
                    if (provider.continueReading != null)
                      ContinueReadingCard(
                        progress: provider.continueReading!,
                        onResume: () => ReadingNavigation.openSurah(
                          context,
                          surahNumber: provider.continueReading!.surahNumber,
                          initialAyah: provider.continueReading!.ayahNumber,
                        ),
                      )
                    else
                      ContinueReadingEmpty(
                        onStart: () => ReadingNavigation.openSurah(
                          context,
                          surahNumber: 1,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    DailyGoalCard(goal: provider.goal),
                    const SizedBox(height: AppSpacing.md),
                    TodayProgressCard(progress: provider.todayProgress),
                    const SizedBox(height: AppSpacing.md),
                    ReadingStreakCard(streak: provider.streak),
                    const SizedBox(height: AppSpacing.md),
                    const InsightsPreviewSection(),
                    const SizedBox(height: AppSpacing.md),
                    if (provider.dailyVerse != null)
                      DailyVerseCard(verse: provider.dailyVerse!)
                    else
                      const DailyVersePlaceholder(),
                    const SizedBox(height: AppSpacing.lg),
                    RecentlyReadSection(
                      readings: provider.recentReadings,
                      onTap: (surahNumber) {
                        final reading = provider.recentReadings.firstWhere(
                          (r) => r.surahNumber == surahNumber,
                        );
                        ReadingNavigation.openSurah(
                          context,
                          surahNumber: surahNumber,
                          initialAyah: reading.ayahNumber,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    QuickActionsSection(
                      onBrowseSurahs: () => ReadingNavigation.openSurahList(context),
                      onSearch: () =>
                          context.read<AppShellProvider>().setIndex(2),
                      onBookmarks: () => TrackingNavigation.openBookmarks(context),
                      onInsights: () => InsightsNavigation.openInsights(context),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
