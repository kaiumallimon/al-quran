import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/app_notification_model.dart';
import '../../features/home/providers/dashboard_provider.dart';
import '../../features/insights/pages/insights_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/notifications/providers/notification_provider.dart';
import 'reading_navigation.dart';
import 'tracking_navigation.dart';

/// Navigation helpers for in-app notifications.
class NotificationNavigation {
  NotificationNavigation._();

  static void openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationsPage(),
      ),
    );
  }

  static Future<void> handleNotification(
    BuildContext context,
    AppNotificationModel notification,
    NotificationProvider provider,
  ) async {
    if (!notification.isRead) {
      await provider.markAsRead(notification.id);
    }

    if (!context.mounted) return;

    switch (notification.action) {
      case AppNotificationAction.continueReading:
        final progress = context.read<DashboardProvider>().continueReading;
        if (progress != null) {
          ReadingNavigation.openSurah(
            context,
            surahNumber: progress.surahNumber,
            initialAyah: progress.ayahNumber,
          );
        } else if (notification.surahNumber != null) {
          ReadingNavigation.openSurah(
            context,
            surahNumber: notification.surahNumber!,
            initialAyah: notification.ayahNumber ?? 1,
          );
        } else {
          ReadingNavigation.openSurah(context, surahNumber: 1);
        }
      case AppNotificationAction.completeGoal:
      case AppNotificationAction.maintainStreak:
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
      case AppNotificationAction.openGoals:
        TrackingNavigation.openHub(context, initialTab: 3);
      case AppNotificationAction.openInsights:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const InsightsPage()),
        );
      case AppNotificationAction.openMilestones:
        TrackingNavigation.openHub(context, initialTab: 4);
      case AppNotificationAction.none:
        break;
    }
  }
}
