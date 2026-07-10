/// Types of in-app notifications.
enum AppNotificationType {
  dailyReminder,
  goalReminder,
  streakReminder,
  milestone,
  readingRecommendation,
  downloadComplete,
  syncComplete,
}

/// Actions when a notification is tapped.
enum AppNotificationAction {
  continueReading,
  completeGoal,
  maintainStreak,
  openGoals,
  openInsights,
  openMilestones,
  none,
}

/// A persisted in-app notification shown in the notification center.
class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.dedupeKey,
    this.isRead = false,
    this.action = AppNotificationAction.none,
    this.surahNumber,
    this.ayahNumber,
  });

  final String id;
  final AppNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String dedupeKey;
  final bool isRead;
  final AppNotificationAction action;
  final int? surahNumber;
  final int? ayahNumber;

  AppNotificationModel copyWith({bool? isRead}) {
    return AppNotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      dedupeKey: dedupeKey,
      isRead: isRead ?? this.isRead,
      action: action,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
  }

  factory AppNotificationModel.fromMap(Map<dynamic, dynamic> map) {
    return AppNotificationModel(
      id: map['id'] as String,
      type: AppNotificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => AppNotificationType.dailyReminder,
      ),
      title: map['title'] as String,
      body: map['body'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      dedupeKey: map['dedupeKey'] as String,
      isRead: map['isRead'] as bool? ?? false,
      action: AppNotificationAction.values.firstWhere(
        (a) => a.name == (map['action'] as String? ?? 'none'),
        orElse: () => AppNotificationAction.none,
      ),
      surahNumber: map['surahNumber'] as int?,
      ayahNumber: map['ayahNumber'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'dedupeKey': dedupeKey,
        'isRead': isRead,
        'action': action.name,
        if (surahNumber != null) 'surahNumber': surahNumber,
        if (ayahNumber != null) 'ayahNumber': ayahNumber,
      };
}
