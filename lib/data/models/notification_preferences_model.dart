/// Reminder schedule presets.
enum NotificationSchedule {
  morning,
  afternoon,
  evening,
  custom,
  disabled,
}

/// User preferences for in-app notification generation.
class NotificationPreferencesModel {
  const NotificationPreferencesModel({
    this.enabled = true,
    this.schedule = NotificationSchedule.evening,
    this.customHour = 20,
    this.customMinute = 0,
    this.smartScheduling = true,
    this.dailyReminder = true,
    this.goalReminder = true,
    this.streakReminder = true,
    this.milestoneNotifications = true,
    this.readingRecommendation = true,
  });

  final bool enabled;
  final NotificationSchedule schedule;
  final int customHour;
  final int customMinute;
  final bool smartScheduling;
  final bool dailyReminder;
  final bool goalReminder;
  final bool streakReminder;
  final bool milestoneNotifications;
  final bool readingRecommendation;

  NotificationPreferencesModel copyWith({
    bool? enabled,
    NotificationSchedule? schedule,
    int? customHour,
    int? customMinute,
    bool? smartScheduling,
    bool? dailyReminder,
    bool? goalReminder,
    bool? streakReminder,
    bool? milestoneNotifications,
    bool? readingRecommendation,
  }) {
    return NotificationPreferencesModel(
      enabled: enabled ?? this.enabled,
      schedule: schedule ?? this.schedule,
      customHour: customHour ?? this.customHour,
      customMinute: customMinute ?? this.customMinute,
      smartScheduling: smartScheduling ?? this.smartScheduling,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      goalReminder: goalReminder ?? this.goalReminder,
      streakReminder: streakReminder ?? this.streakReminder,
      milestoneNotifications:
          milestoneNotifications ?? this.milestoneNotifications,
      readingRecommendation:
          readingRecommendation ?? this.readingRecommendation,
    );
  }

  factory NotificationPreferencesModel.fromMap(Map<dynamic, dynamic> map) {
    return NotificationPreferencesModel(
      enabled: map['enabled'] as bool? ?? true,
      schedule: NotificationSchedule.values.firstWhere(
        (s) => s.name == (map['schedule'] as String? ?? 'evening'),
        orElse: () => NotificationSchedule.evening,
      ),
      customHour: map['customHour'] as int? ?? 20,
      customMinute: map['customMinute'] as int? ?? 0,
      smartScheduling: map['smartScheduling'] as bool? ?? true,
      dailyReminder: map['dailyReminder'] as bool? ?? true,
      goalReminder: map['goalReminder'] as bool? ?? true,
      streakReminder: map['streakReminder'] as bool? ?? true,
      milestoneNotifications: map['milestoneNotifications'] as bool? ?? true,
      readingRecommendation: map['readingRecommendation'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'schedule': schedule.name,
        'customHour': customHour,
        'customMinute': customMinute,
        'smartScheduling': smartScheduling,
        'dailyReminder': dailyReminder,
        'goalReminder': goalReminder,
        'streakReminder': streakReminder,
        'milestoneNotifications': milestoneNotifications,
        'readingRecommendation': readingRecommendation,
      };
}
