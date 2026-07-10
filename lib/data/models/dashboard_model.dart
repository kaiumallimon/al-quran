import 'daily_verse_model.dart';
import 'reading_progress_model.dart';

/// A recently read surah entry for the dashboard.
class RecentReadingModel {
  const RecentReadingModel({
    required this.surahNumber,
    required this.englishName,
    required this.surahName,
    required this.lastReadAt,
    required this.ayahNumber,
  });

  final int surahNumber;
  final String englishName;
  final String surahName;
  final DateTime lastReadAt;
  final int ayahNumber;
}

/// Summary of today's reading activity.
class TodayProgressModel {
  const TodayProgressModel({
    this.readingMinutes = 0,
    this.pagesRead = 0,
    this.ayahsRead = 0,
    this.sessions = 0,
  });

  final int readingMinutes;
  final int pagesRead;
  final int ayahsRead;
  final int sessions;
}

/// Reading streak information.
class StreakModel {
  const StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastReadDate,
  });

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadDate;

  factory StreakModel.fromMap(Map<dynamic, dynamic> map) {
    return StreakModel(
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastReadDate: map['lastReadDate'] != null
          ? DateTime.parse(map['lastReadDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        if (lastReadDate != null)
          'lastReadDate': lastReadDate!.toIso8601String(),
      };
}

/// Daily reading goal progress.
class GoalModel {
  const GoalModel({
    required this.targetAyahs,
    this.completedAyahs = 0,
    this.type = 'daily',
  });

  final int targetAyahs;
  final int completedAyahs;
  final String type;

  double get progressPercent =>
      targetAyahs > 0 ? (completedAyahs / targetAyahs).clamp(0.0, 1.0) : 0;

  int get remainingAyahs =>
      (targetAyahs - completedAyahs).clamp(0, targetAyahs);

  factory GoalModel.fromMap(Map<dynamic, dynamic> map) {
    return GoalModel(
      targetAyahs: map['targetAyahs'] as int,
      completedAyahs: map['completedAyahs'] as int? ?? 0,
      type: map['type'] as String? ?? 'daily',
    );
  }

  Map<String, dynamic> toMap() => {
        'targetAyahs': targetAyahs,
        'completedAyahs': completedAyahs,
        'type': type,
      };
}

/// Aggregated dashboard data.
class DashboardModel {
  const DashboardModel({
    this.continueReading,
    this.dailyVerse,
    this.todayProgress = const TodayProgressModel(),
    this.streak = const StreakModel(),
    this.goal = const GoalModel(targetAyahs: 10),
    this.recentReadings = const [],
  });

  final ReadingProgressModel? continueReading;
  final DailyVerseModel? dailyVerse;
  final TodayProgressModel todayProgress;
  final StreakModel streak;
  final GoalModel goal;
  final List<RecentReadingModel> recentReadings;
}
