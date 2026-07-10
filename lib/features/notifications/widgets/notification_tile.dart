import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/app_notification_model.dart';

/// Single in-app notification list item.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  final AppNotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUnread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: colorScheme.error.withValues(alpha: 0.15),
        child: Icon(Icons.delete_outline, color: colorScheme.error),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isUnread
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            _iconFor(notification.type),
            color: isUnread
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: AppTypography.body(context).copyWith(
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              notification.body,
              style: AppTypography.caption(context).copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatTime(notification.createdAt),
              style: AppTypography.small(context).copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  IconData _iconFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.dailyReminder:
        return Icons.wb_sunny_outlined;
      case AppNotificationType.goalReminder:
        return Icons.flag_outlined;
      case AppNotificationType.streakReminder:
        return Icons.local_fire_department_outlined;
      case AppNotificationType.milestone:
        return Icons.emoji_events_outlined;
      case AppNotificationType.readingRecommendation:
        return Icons.lightbulb_outline;
      case AppNotificationType.downloadComplete:
        return Icons.download_done_outlined;
      case AppNotificationType.syncComplete:
        return Icons.cloud_done_outlined;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return DateFormat.jm().format(date);
    if (diff.inDays < 7) return DateFormat.E().add_jm().format(date);
    return DateFormat.MMMd().add_jm().format(date);
  }
}
