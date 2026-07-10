import '../datasources/local/notification_local_datasource.dart';
import '../models/app_notification_model.dart';
import '../models/dashboard_model.dart';
import '../models/notification_preferences_model.dart';
import '../models/reading_progress_model.dart';
import '../models/reading_session_model.dart';
import '../models/recommendation_model.dart';
import 'dashboard_repository.dart';
import 'insights_repository.dart';
import 'tracking_repository.dart';

/// Repository for in-app notification generation, scheduling, and persistence.
class NotificationRepository {
  NotificationRepository({
    required NotificationLocalDataSource local,
    required DashboardRepository dashboardRepository,
    required InsightsRepository insightsRepository,
    required TrackingRepository trackingRepository,
  })  : _local = local,
        _dashboard = dashboardRepository,
        _insights = insightsRepository,
        _tracking = trackingRepository;

  final NotificationLocalDataSource _local;
  final DashboardRepository _dashboard;
  final InsightsRepository _insights;
  final TrackingRepository _tracking;

  Future<List<AppNotificationModel>> getNotifications() => _local.getAll();

  Future<int> getUnreadCount() => _local.getUnreadCount();

  Future<NotificationPreferencesModel> getPreferences() =>
      _local.getPreferences();

  Future<void> savePreferences(NotificationPreferencesModel preferences) =>
      _local.savePreferences(preferences);

  Future<void> markAsRead(String id) => _local.markAsRead(id);

  Future<void> markAllAsRead() => _local.markAllAsRead();

  Future<void> dismiss(String id) => _local.delete(id);

  Future<void> clearAll() => _local.clearAll();

  /// Generates new in-app notifications based on habits and current progress.
  Future<List<AppNotificationModel>> syncNotifications() async {
    final prefs = await _local.getPreferences();
    if (!prefs.enabled || prefs.schedule == NotificationSchedule.disabled) {
      return _local.getAll();
    }

    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final streak = await _dashboard.getStreak();
    final goal = await _dashboard.getDailyGoal();
    final progress = await _dashboard.getContinueReading();
    final sessions = await _tracking.getAllSessions();
    final milestones = await _tracking.getMilestones();
    final recommendations = await _insights.getRecommendations();
    final hasReadToday = !_hasNotReadToday(streak);

    if (!_isPastPreferredTime(now, sessions, prefs)) {
      return _local.getAll();
    }

    if (prefs.dailyReminder && !hasReadToday) {
      await _maybeCreate(
        dedupeKey: 'daily_$todayKey',
        type: AppNotificationType.dailyReminder,
        title: 'Continue your Quran journey',
        body: 'Take a few peaceful minutes with the Quran today.',
        action: AppNotificationAction.continueReading,
        progress: progress,
      );
    }

    if (prefs.goalReminder && goal.remainingAyahs > 0) {
      final body = goal.remainingAyahs == 1
          ? 'You are only 1 ayah away from today\'s goal.'
          : 'You are only ${goal.remainingAyahs} ayahs away from today\'s goal.';
      await _maybeCreate(
        dedupeKey: 'goal_$todayKey',
        type: AppNotificationType.goalReminder,
        title: 'Almost at your daily goal',
        body: body,
        action: AppNotificationAction.completeGoal,
        progress: progress,
      );
    }

    if (prefs.streakReminder &&
        streak.currentStreak > 0 &&
        !hasReadToday) {
      await _maybeCreate(
        dedupeKey: 'streak_$todayKey',
        type: AppNotificationType.streakReminder,
        title: 'Keep your streak alive',
        body:
            'Your ${streak.currentStreak}-day streak can continue with a short reading today.',
        action: AppNotificationAction.maintainStreak,
        progress: progress,
      );
    }

    if (prefs.readingRecommendation && recommendations.isNotEmpty) {
      final rec = recommendations.first;
      await _maybeCreate(
        dedupeKey: 'recommendation_$todayKey',
        type: AppNotificationType.readingRecommendation,
        title: rec.title,
        body: rec.description,
        action: _actionFromRecommendation(rec),
        progress: progress,
        surahNumber: rec.surahNumber,
        ayahNumber: rec.ayahNumber,
      );
    }

    if (prefs.milestoneNotifications) {
      for (final milestone in milestones) {
        if (_isToday(milestone.achievedAt)) {
          await _maybeCreate(
            dedupeKey: 'milestone_${milestone.type}_$todayKey',
            type: AppNotificationType.milestone,
            title: milestone.title,
            body: milestone.description,
            action: AppNotificationAction.openMilestones,
          );
        }
      }
    }

    return _local.getAll();
  }

  Future<void> _maybeCreate({
    required String dedupeKey,
    required AppNotificationType type,
    required String title,
    required String body,
    required AppNotificationAction action,
    ReadingProgressModel? progress,
    int? surahNumber,
    int? ayahNumber,
  }) async {
    if (await _local.existsByDedupeKey(dedupeKey)) return;

    await _local.save(AppNotificationModel(
      id: _local.generateId(),
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      dedupeKey: dedupeKey,
      action: action,
      surahNumber: surahNumber ?? progress?.surahNumber,
      ayahNumber: ayahNumber ?? progress?.ayahNumber,
    ));
  }

  bool _isPastPreferredTime(
    DateTime now,
    List<ReadingSessionModel> sessions,
    NotificationPreferencesModel prefs,
  ) {
    final hour = _preferredHour(sessions, prefs);
    if (hour < 0) return false;

    final minute = prefs.schedule == NotificationSchedule.custom
        ? prefs.customMinute
        : 0;

    if (now.hour > hour) return true;
    return now.hour == hour && now.minute >= minute;
  }

  int _preferredHour(
    List<ReadingSessionModel> sessions,
    NotificationPreferencesModel prefs,
  ) {
    if (prefs.smartScheduling && sessions.length >= 3) {
      final peak = _peakHour(sessions);
      if (peak >= 0) return peak;
    }

    switch (prefs.schedule) {
      case NotificationSchedule.morning:
        return 7;
      case NotificationSchedule.afternoon:
        return 14;
      case NotificationSchedule.evening:
        return 20;
      case NotificationSchedule.custom:
        return prefs.customHour.clamp(0, 23);
      case NotificationSchedule.disabled:
        return -1;
    }
  }

  int _peakHour(List<ReadingSessionModel> sessions) {
    final counts = List<int>.filled(24, 0);
    for (final session in sessions) {
      counts[session.startedAt.hour]++;
    }

    var max = 0;
    var index = -1;
    for (var i = 0; i < counts.length; i++) {
      if (counts[i] > max) {
        max = counts[i];
        index = i;
      }
    }
    return max > 0 ? index : -1;
  }

  AppNotificationAction _actionFromRecommendation(RecommendationModel rec) {
    switch (rec.action) {
      case RecommendationAction.continueReading:
        return AppNotificationAction.continueReading;
      case RecommendationAction.completeGoal:
        return AppNotificationAction.completeGoal;
      case RecommendationAction.maintainStreak:
        return AppNotificationAction.maintainStreak;
      case RecommendationAction.openSurah:
        return AppNotificationAction.continueReading;
      case RecommendationAction.openGoals:
        return AppNotificationAction.openGoals;
      case RecommendationAction.openInsights:
        return AppNotificationAction.openInsights;
    }
  }

  bool _hasNotReadToday(StreakModel streak) {
    if (streak.lastReadDate == null) return true;
    return !_isToday(streak.lastReadDate!);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';
}
