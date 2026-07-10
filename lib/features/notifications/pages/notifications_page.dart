import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/notification_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_settings_sheet.dart';
import '../widgets/notification_tile.dart';

/// In-app notification center.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Reminder settings',
            onPressed: () => NotificationSettingsSheet.show(context),
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: provider.markAllAsRead,
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.status == NotificationStatus.loading &&
              provider.notifications.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const [
                SkeletonLoader(height: 72),
                SizedBox(height: AppSpacing.sm),
                SkeletonLoader(height: 72),
              ],
            );
          }

          if (provider.status == NotificationStatus.error &&
              provider.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ErrorStateWidget(
                  message: provider.errorMessage ?? 'Something went wrong',
                  onRetry: provider.loadNotifications,
                ),
              ),
            );
          }

          if (!provider.preferences.enabled) {
            return EmptyStateWidget(
              icon: Icons.notifications_off_outlined,
              title: 'Reminders are off',
              subtitle:
                  'Enable gentle in-app reminders to stay consistent with your reading.',
              actionLabel: 'Open settings',
              onAction: () => NotificationSettingsSheet.show(context),
            );
          }

          if (provider.notifications.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_none_outlined,
              title: 'No notifications yet',
              subtitle:
                  'Reminders will appear here when it is time to read, based on your schedule.',
              actionLabel: 'Adjust schedule',
              onAction: () => NotificationSettingsSheet.show(context),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => NotificationNavigation.handleNotification(
                    context,
                    notification,
                    provider,
                  ),
                  onDismiss: () => provider.dismiss(notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
