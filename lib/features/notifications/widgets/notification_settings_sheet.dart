import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/notification_preferences_model.dart';
import '../providers/notification_provider.dart';

/// Bottom sheet for configuring in-app notification preferences.
class NotificationSettingsSheet extends StatelessWidget {
  const NotificationSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const NotificationSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final prefs = provider.preferences;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Reminder Settings', style: AppTypography.subtitle(context)),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  title: const Text('Enable reminders'),
                  subtitle: const Text('Gentle in-app reminders only'),
                  value: prefs.enabled,
                  onChanged: provider.toggleEnabled,
                ),
                const Divider(),
                Text('Schedule', style: AppTypography.caption(context)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _ScheduleChip(
                      label: 'Morning',
                      selected: prefs.schedule == NotificationSchedule.morning,
                      onTap: prefs.enabled
                          ? () => provider.setSchedule(
                                NotificationSchedule.morning,
                              )
                          : null,
                    ),
                    _ScheduleChip(
                      label: 'Afternoon',
                      selected:
                          prefs.schedule == NotificationSchedule.afternoon,
                      onTap: prefs.enabled
                          ? () => provider.setSchedule(
                                NotificationSchedule.afternoon,
                              )
                          : null,
                    ),
                    _ScheduleChip(
                      label: 'Evening',
                      selected: prefs.schedule == NotificationSchedule.evening,
                      onTap: prefs.enabled
                          ? () => provider.setSchedule(
                                NotificationSchedule.evening,
                              )
                          : null,
                    ),
                    _ScheduleChip(
                      label: 'Custom',
                      selected: prefs.schedule == NotificationSchedule.custom,
                      onTap: prefs.enabled
                          ? () => _pickCustomTime(context, provider, prefs)
                          : null,
                    ),
                    _ScheduleChip(
                      label: 'Disabled',
                      selected: prefs.schedule == NotificationSchedule.disabled,
                      onTap: prefs.enabled
                          ? () => provider.setSchedule(
                                NotificationSchedule.disabled,
                              )
                          : null,
                    ),
                  ],
                ),
                if (prefs.schedule == NotificationSchedule.custom) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Custom time: ${_formatTime(prefs.customHour, prefs.customMinute)}',
                    style: AppTypography.caption(context),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  title: const Text('Smart scheduling'),
                  subtitle: const Text('Adapt to your usual reading time'),
                  value: prefs.smartScheduling,
                  onChanged: prefs.enabled
                      ? (v) => provider.updatePreferences(
                            prefs.copyWith(smartScheduling: v),
                          )
                      : null,
                ),
                const Divider(),
                Text('Reminder types', style: AppTypography.caption(context)),
                _TypeSwitch(
                  title: 'Daily reminder',
                  value: prefs.dailyReminder,
                  enabled: prefs.enabled,
                  onChanged: (v) =>
                      provider.updatePreferences(prefs.copyWith(dailyReminder: v)),
                ),
                _TypeSwitch(
                  title: 'Goal reminder',
                  value: prefs.goalReminder,
                  enabled: prefs.enabled,
                  onChanged: (v) =>
                      provider.updatePreferences(prefs.copyWith(goalReminder: v)),
                ),
                _TypeSwitch(
                  title: 'Streak reminder',
                  value: prefs.streakReminder,
                  enabled: prefs.enabled,
                  onChanged: (v) =>
                      provider.updatePreferences(prefs.copyWith(streakReminder: v)),
                ),
                _TypeSwitch(
                  title: 'Milestones',
                  value: prefs.milestoneNotifications,
                  enabled: prefs.enabled,
                  onChanged: (v) => provider.updatePreferences(
                    prefs.copyWith(milestoneNotifications: v),
                  ),
                ),
                _TypeSwitch(
                  title: 'Reading suggestions',
                  value: prefs.readingRecommendation,
                  enabled: prefs.enabled,
                  onChanged: (v) => provider.updatePreferences(
                    prefs.copyWith(readingRecommendation: v),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickCustomTime(
    BuildContext context,
    NotificationProvider provider,
    NotificationPreferencesModel prefs,
  ) async {
    final initial = TimeOfDay(
      hour: prefs.customHour,
      minute: prefs.customMinute,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      await provider.setCustomTime(picked.hour, picked.minute);
    }
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:${minute.toString().padLeft(2, '0')} $period';
  }
}

class _ScheduleChip extends StatelessWidget {
  const _ScheduleChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
    );
  }
}

class _TypeSwitch extends StatelessWidget {
  const _TypeSwitch({
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: enabled ? onChanged : null,
      dense: true,
    );
  }
}
