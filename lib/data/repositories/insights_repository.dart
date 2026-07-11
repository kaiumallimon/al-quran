import '../../../core/utils/juz_helper.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../models/dashboard_model.dart';
import '../models/insight_model.dart';
import '../models/reading_progress_model.dart';
import '../models/reading_session_model.dart';
import '../models/reading_summary_model.dart';
import '../models/recommendation_model.dart';
import '../models/surah_model.dart';
import 'dashboard_repository.dart';
import 'tracking_repository.dart';

/// Repository for reading insights and gentle recommendations.
class InsightsRepository {
  InsightsRepository({
    required HiveLocalDataSource hiveLocal,
    required DashboardRepository dashboardRepository,
    required TrackingRepository trackingRepository,
  })  : _hive = hiveLocal,
        _dashboard = dashboardRepository,
        _tracking = trackingRepository;

  final HiveLocalDataSource _hive;
  final DashboardRepository _dashboard;
  final TrackingRepository _tracking;

  Future<List<InsightModel>> generateInsights() async {
    final sessions = await _getAllSessions();
    final streak = await _dashboard.getStreak();
    final goal = await _dashboard.getDailyGoal();
    final progress = await _dashboard.getContinueReading();
    final surahs = await _hive.getSurahs();

    final insights = <InsightModel>[];

    insights.addAll(_timePatternInsights(sessions));
    insights.addAll(_sessionInsights(sessions));
    insights.addAll(_streakInsights(streak));
    insights.addAll(_goalInsights(goal));
    insights.addAll(_juzInsights(progress));
    insights.addAll(_weeklyComparisonInsights(sessions));
    insights.addAll(_surahInsights(sessions, surahs));

    insights.sort((a, b) => a.category.index.compareTo(b.category.index));
    return insights;
  }

  Future<List<RecommendationModel>> getRecommendations() async {
    final progress = await _dashboard.getContinueReading();
    final goal = await _dashboard.getDailyGoal();
    final streak = await _dashboard.getStreak();
    final sessions = await _getAllSessions();
    final goals = await _tracking.getGoals();
    final surahs = await _hive.getSurahs();

    final recommendations = <RecommendationModel>[];

    if (progress != null) {
      recommendations.add(RecommendationModel(
        id: 'continue_reading',
        title: 'Continue reading',
        description: progress.englishName != null
            ? 'Pick up where you left off in ${progress.englishName}.'
            : 'Resume your last reading session.',
        action: RecommendationAction.continueReading,
        priority: 100,
        surahNumber: progress.surahNumber,
        ayahNumber: progress.ayahNumber,
      ));
    }

    if (goal.remainingAyahs > 0) {
      recommendations.add(RecommendationModel(
        id: 'complete_goal',
        title: "Complete today's goal",
        description: goal.remainingAyahs == 1
            ? 'Just 1 more ayah to reach your daily target.'
            : 'Only ${goal.remainingAyahs} ayahs left for today.',
        action: RecommendationAction.completeGoal,
        priority: 90,
      ));
    }

    if (_hasNotReadToday(streak) && streak.currentStreak > 0) {
      recommendations.add(RecommendationModel(
        id: 'maintain_streak',
        title: 'Keep your streak alive',
        description:
            'Your ${streak.currentStreak}-day streak can continue with a short reading today.',
        action: RecommendationAction.maintainStreak,
        priority: 80,
      ));
    }

    final juzRec = _juzRecommendation(progress);
    if (juzRec != null) recommendations.add(juzRec);

    final activeGoal = goals.where((g) => !g.isComplete).toList()
      ..sort((a, b) => a.remaining.compareTo(b.remaining));
    if (activeGoal.isNotEmpty && activeGoal.first.remaining <= 5) {
      final g = activeGoal.first;
      recommendations.add(RecommendationModel(
        id: 'goal_near_complete',
        title: 'Almost there',
        description:
            'Only ${g.remaining} ${g.unit} left on your ${g.type} goal.',
        action: RecommendationAction.openGoals,
        priority: 70,
      ));
    }

    final timeRec = _usualTimeRecommendation(sessions);
    if (timeRec != null) recommendations.add(timeRec);

    final surahRec = _suggestedSurahRecommendation(sessions, surahs, progress);
    if (surahRec != null) recommendations.add(surahRec);

    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    return recommendations;
  }

  Future<ReadingSummaryModel> getWeeklySummary() async {
    final sessions = await _sessionsInRange(_weekStart(DateTime.now()), null);
    return _buildSummary(sessions, await _hive.getSurahs());
  }

  Future<ReadingSummaryModel> getMonthlySummary() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final sessions = await _sessionsInRange(start, null);
    return _buildSummary(sessions, await _hive.getSurahs());
  }

  Future<ReadingSummaryModel> getLifetimeSummary() async {
    final sessions = await _getAllSessions();
    return _buildSummary(sessions, await _hive.getSurahs());
  }

  Future<List<DailyActivityModel>> getWeeklyActivity() async {
    final start = _weekStart(DateTime.now());
    final sessions = await _sessionsInRange(start, null);
    return _dailyActivity(sessions, start, 7);
  }

  Future<List<DailyActivityModel>> getMonthlyActivity() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final sessions = await _sessionsInRange(start, null);
    return _dailyActivity(sessions, start, daysInMonth);
  }

  Future<List<ReadingSessionModel>> _getAllSessions() async {
    final hiveSessions = await _hive.getAllSessions();
    final trackingSessions = await _tracking.getAllSessions();

    final byId = <String, ReadingSessionModel>{};
    for (final session in [...hiveSessions, ...trackingSessions]) {
      byId[session.id] = session;
    }

    final merged = byId.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return merged;
  }

  Future<List<ReadingSessionModel>> _sessionsInRange(
    DateTime start,
    DateTime? end,
  ) async {
    final all = await _getAllSessions();
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = end != null
        ? DateTime(end.year, end.month, end.day, 23, 59, 59)
        : null;

    return all.where((s) {
      if (s.startedAt.isBefore(startDate)) return false;
      if (endDate != null && s.startedAt.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  List<InsightModel> _timePatternInsights(List<ReadingSessionModel> sessions) {
    if (sessions.length < 3) return [];

    final hourCounts = List<int>.filled(24, 0);
    final dayCounts = List<int>.filled(7, 0);

    for (final session in sessions) {
      hourCounts[session.startedAt.hour]++;
      dayCounts[session.startedAt.weekday - 1]++;
    }

    final insights = <InsightModel>[];
    final peakHour = _peakIndex(hourCounts);
    final peakDay = _peakIndex(dayCounts);

    if (peakHour >= 0) {
      insights.add(InsightModel(
        id: 'peak_time',
        message: 'You usually read ${_timeLabel(peakHour)}.',
        category: InsightCategory.weekly,
        icon: 'schedule',
      ));
    }

    if (peakDay >= 0) {
      insights.add(InsightModel(
        id: 'peak_day',
        message:
            'You read most consistently on ${_weekdayLabel(peakDay)}s.',
        category: InsightCategory.weekly,
        icon: 'calendar_today',
      ));
    }

    return insights;
  }

  List<InsightModel> _sessionInsights(List<ReadingSessionModel> sessions) {
    if (sessions.isEmpty) return [];

    var totalMinutes = 0;
    var counted = 0;
    for (final session in sessions) {
      final minutes = session.durationMinutes > 0
          ? session.durationMinutes
          : session.ayahsRead > 0
              ? (session.ayahsRead * 0.5).ceil()
              : 0;
      if (minutes > 0) {
        totalMinutes += minutes;
        counted++;
      }
    }

    if (counted == 0) return [];

    final average = (totalMinutes / counted).round();
    return [
      InsightModel(
        id: 'avg_session',
        message: 'Your average reading session lasts $average minutes.',
        category: InsightCategory.lifetime,
        icon: 'timer',
      ),
    ];
  }

  List<InsightModel> _streakInsights(StreakModel streak) {
    if (streak.currentStreak <= 0) return [];

    return [
      InsightModel(
        id: 'current_streak',
        message: streak.currentStreak == 1
            ? "You've started a reading streak — keep it going."
            : "You've maintained a reading streak for ${streak.currentStreak} days.",
        category: InsightCategory.daily,
        icon: 'local_fire_department',
      ),
    ];
  }

  List<InsightModel> _goalInsights(GoalModel goal) {
    if (goal.targetAyahs <= 0) return [];

    if (goal.completedAyahs >= goal.targetAyahs) {
      return const [
        InsightModel(
          id: 'goal_complete',
          message: "You've completed today's reading goal.",
          category: InsightCategory.daily,
          icon: 'check_circle',
        ),
      ];
    }

    return [
      InsightModel(
        id: 'goal_progress',
        message:
            "You're ${(goal.progressPercent * 100).round()}% toward today's goal.",
        category: InsightCategory.daily,
        icon: 'flag',
      ),
    ];
  }

  List<InsightModel> _juzInsights(ReadingProgressModel? progress) {
    if (progress == null || progress.page <= 0) return [];

    final pagesLeft = JuzHelper.pagesUntilJuzEnd(progress.page);
    if (pagesLeft <= 0 || pagesLeft > 15) return [];

    final juz = JuzHelper.juzForPage(progress.page);
    return [
      InsightModel(
        id: 'juz_progress',
        message: pagesLeft == 1
            ? 'You are 1 page away from completing Juz $juz.'
            : 'You are $pagesLeft pages away from completing Juz $juz.',
        category: InsightCategory.weekly,
        icon: 'auto_stories',
      ),
    ];
  }

  List<InsightModel> _weeklyComparisonInsights(
    List<ReadingSessionModel> sessions,
  ) {
    final now = DateTime.now();
    final thisWeekStart = _weekStart(now);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(seconds: 1));

    var thisWeekAyahs = 0;
    var lastWeekAyahs = 0;

    for (final session in sessions) {
      if (!session.startedAt.isBefore(thisWeekStart)) {
        thisWeekAyahs += session.ayahsRead;
      } else if (!session.startedAt.isBefore(lastWeekStart) &&
          !session.startedAt.isAfter(lastWeekEnd)) {
        lastWeekAyahs += session.ayahsRead;
      }
    }

    if (thisWeekAyahs == 0 && lastWeekAyahs == 0) return [];

    if (lastWeekAyahs == 0) {
      return [
        InsightModel(
          id: 'week_start',
          message: "You've read $thisWeekAyahs ayahs so far this week.",
          category: InsightCategory.weekly,
          icon: 'trending_up',
        ),
      ];
    }

    final change =
        ((thisWeekAyahs - lastWeekAyahs) / lastWeekAyahs * 100).round();
    if (change.abs() < 10) return [];

    if (change > 0) {
      return [
        InsightModel(
          id: 'week_improved',
          message:
              'You have improved your weekly reading by $change% compared to last week.',
          category: InsightCategory.weekly,
          icon: 'trending_up',
        ),
      ];
    }

    return const [
      InsightModel(
        id: 'week_gentle',
        message:
            'A short reading today can help you reconnect with your rhythm.',
        category: InsightCategory.weekly,
        icon: 'self_improvement',
      ),
    ];
  }

  List<InsightModel> _surahInsights(
    List<ReadingSessionModel> sessions,
    List<SurahModel> surahs,
  ) {
    if (sessions.isEmpty) return [];

    final counts = <int, int>{};
    for (final session in sessions) {
      if (session.surahNumber != null) {
        counts[session.surahNumber!] =
            (counts[session.surahNumber!] ?? 0) + session.ayahsRead;
      }
    }

    if (counts.isEmpty) return [];

    final topEntry = counts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final surah = surahs.where((s) => s.number == topEntry.key).firstOrNull;

    if (surah == null) return [];

    return [
      InsightModel(
        id: 'most_read_surah',
        message: '${surah.englishName} is your most visited surah.',
        category: InsightCategory.monthly,
        icon: 'menu_book',
      ),
    ];
  }

  RecommendationModel? _juzRecommendation(ReadingProgressModel? progress) {
    if (progress == null || progress.page <= 0) return null;

    final pagesLeft = JuzHelper.pagesUntilJuzEnd(progress.page);
    if (pagesLeft <= 0 || pagesLeft > 10) return null;

    final juz = JuzHelper.juzForPage(progress.page);
    return RecommendationModel(
      id: 'juz_near',
      title: 'Close to completing Juz $juz',
      description: pagesLeft == 1
          ? 'Just 1 more page to finish this juz.'
          : 'Only $pagesLeft pages left in this juz.',
      action: RecommendationAction.continueReading,
      priority: 75,
      surahNumber: progress.surahNumber,
      ayahNumber: progress.ayahNumber,
    );
  }

  RecommendationModel? _usualTimeRecommendation(
    List<ReadingSessionModel> sessions,
  ) {
    if (sessions.length < 5) return null;

    final hourCounts = List<int>.filled(24, 0);
    for (final session in sessions) {
      hourCounts[session.startedAt.hour]++;
    }

    final peakHour = _peakIndex(hourCounts);
    if (peakHour < 0) return null;

    final now = DateTime.now();
    final hourDiff = (now.hour - peakHour).abs();
    if (hourDiff > 2) return null;

    return RecommendationModel(
      id: 'usual_time',
      title: 'A good time to read',
      description: 'You usually read around ${_timeLabel(peakHour)}.',
      action: RecommendationAction.continueReading,
      priority: 50,
    );
  }

  RecommendationModel? _suggestedSurahRecommendation(
    List<ReadingSessionModel> sessions,
    List<SurahModel> surahs,
    ReadingProgressModel? progress,
  ) {
    if (surahs.isEmpty) return null;

    final readSurahs = sessions
        .where((s) => s.surahNumber != null)
        .map((s) => s.surahNumber!)
        .toSet();

    final unread = surahs.where((s) => !readSurahs.contains(s.number)).toList();
    if (unread.isEmpty) return null;

    final suggested = unread.first;
    return RecommendationModel(
      id: 'explore_surah',
      title: 'Explore ${suggested.englishName}',
      description: 'You have not visited this surah yet.',
      action: RecommendationAction.openSurah,
      priority: 40,
      surahNumber: suggested.number,
      ayahNumber: progress?.ayahNumber ?? 1,
    );
  }

  ReadingSummaryModel _buildSummary(
    List<ReadingSessionModel> sessions,
    List<SurahModel> surahs,
  ) {
    var minutes = 0;
    var pages = 0;
    var ayahs = 0;
    final activeDays = <DateTime>{};
    final surahCounts = <int, int>{};
    final dailyAyahs = <DateTime, int>{};

    for (final session in sessions) {
      minutes += session.durationMinutes > 0
          ? session.durationMinutes
          : (session.ayahsRead * 0.5).ceil();
      pages += session.pagesRead;
      ayahs += session.ayahsRead;

      final day = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      activeDays.add(day);
      dailyAyahs[day] = (dailyAyahs[day] ?? 0) + session.ayahsRead;

      if (session.surahNumber != null) {
        surahCounts[session.surahNumber!] =
            (surahCounts[session.surahNumber!] ?? 0) + session.ayahsRead;
      }
    }

    var bestDay = DateTime.now();
    var bestAyahs = 0;
    for (final entry in dailyAyahs.entries) {
      if (entry.value > bestAyahs) {
        bestAyahs = entry.value;
        bestDay = entry.key;
      }
    }

    int? topSurah;
    String? topSurahName;
    if (surahCounts.isNotEmpty) {
      topSurah = surahCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      topSurahName = surahs
          .where((s) => s.number == topSurah)
          .map((s) => s.englishName)
          .firstOrNull;
    }

    final avgSession = sessions.isEmpty
        ? 0
        : (minutes / sessions.length).round();

    return ReadingSummaryModel(
      readingMinutes: minutes,
      pagesRead: pages,
      ayahsRead: ayahs,
      sessions: sessions.length,
      activeDays: activeDays.length,
      averageSessionMinutes: avgSession,
      mostReadSurahNumber: topSurah,
      mostReadSurahName: topSurahName,
      bestDayAyahs: bestAyahs,
      bestDayDate: bestAyahs > 0 ? bestDay : null,
    );
  }

  List<DailyActivityModel> _dailyActivity(
    List<ReadingSessionModel> sessions,
    DateTime start,
    int days,
  ) {
    final result = <DailyActivityModel>[];

    for (var i = 0; i < days; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      final daySessions = sessions.where((s) {
        return s.startedAt.year == date.year &&
            s.startedAt.month == date.month &&
            s.startedAt.day == date.day;
      });

      var ayahs = 0;
      var minutes = 0;
      var count = 0;
      for (final session in daySessions) {
        ayahs += session.ayahsRead;
        minutes += session.durationMinutes > 0
            ? session.durationMinutes
            : (session.ayahsRead * 0.5).ceil();
        count++;
      }

      result.add(DailyActivityModel(
        date: date,
        ayahsRead: ayahs,
        minutes: minutes,
        sessions: count,
      ));
    }

    return result;
  }

  bool _hasNotReadToday(StreakModel streak) {
    if (streak.lastReadDate == null) return true;
    final today = DateTime.now();
    final last = streak.lastReadDate!;
    return last.year != today.year ||
        last.month != today.month ||
        last.day != today.day;
  }

  DateTime _weekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  int _peakIndex(List<int> counts) {
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

  String _timeLabel(int hour) {
    if (hour >= 4 && hour < 6) return 'around Fajr';
    if (hour >= 6 && hour < 12) return 'in the morning';
    if (hour >= 12 && hour < 15) return 'around Dhuhr';
    if (hour >= 15 && hour < 18) return 'in the afternoon';
    if (hour >= 18 && hour < 20) return 'after Maghrib';
    if (hour >= 20 && hour < 23) return 'in the evening';
    return 'at night';
  }

  String _weekdayLabel(int index) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[index.clamp(0, 6)];
  }
}
