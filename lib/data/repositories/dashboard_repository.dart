import '../../../core/utils/logger.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../models/daily_verse_model.dart';
import '../models/dashboard_model.dart';
import '../models/reading_progress_model.dart';
import '../models/reading_session_model.dart';
import 'quran_repository.dart';

/// Repository for home dashboard data.
class DashboardRepository {
  DashboardRepository({
    required HiveLocalDataSource local,
    required QuranRepository quranRepository,
  })  : _local = local,
        _quran = quranRepository;

  final HiveLocalDataSource _local;
  final QuranRepository _quran;
  static const _tag = 'DashboardRepository';

  Future<DashboardModel> getDashboard() async {
    final results = await Future.wait([
      getContinueReading(),
      getDailyVerse(),
      getTodayProgress(),
      getStreak(),
      getDailyGoal(),
      getRecentReading(),
    ]);

    return DashboardModel(
      continueReading: results[0] as ReadingProgressModel?,
      dailyVerse: results[1] as DailyVerseModel?,
      todayProgress: results[2] as TodayProgressModel,
      streak: results[3] as StreakModel,
      goal: results[4] as GoalModel,
      recentReadings: results[5] as List<RecentReadingModel>,
    );
  }

  Future<ReadingProgressModel?> getContinueReading() async {
    return _local.getReadingProgress();
  }

  Future<DailyVerseModel?> getDailyVerse() async {
    final cached = await _local.getDailyVerse();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (cached != null) {
      final cachedDate = DateTime(
        cached.date.year,
        cached.date.month,
        cached.date.day,
      );
      if (cachedDate == todayDate) return cached;
    }

    _refreshDailyVerseInBackground();
    return cached;
  }

  Future<DailyVerseModel> _fetchAndCacheDailyVerse() async {
    try {
      final ayahNumber = _getDailyVerseNumber();
      final ayah = await _quran.getAyahWithTranslations(ayahNumber);
      final surahs = await _local.getSurahs();
      final surah = surahs.firstWhere(
        (s) => s.number == ayah.surahNumber,
        orElse: () => surahs.isNotEmpty
            ? surahs.first
            : throw StateError('No surahs cached'),
      );

      final verse = DailyVerseModel(
        ayah: ayah,
        surahName: surah.name,
        englishName: surah.englishName,
        date: DateTime.now(),
      );
      await _local.saveDailyVerse(verse);
      return verse;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch daily verse', e);
      rethrow;
    }
  }

  int _getDailyVerseNumber() {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return (dayOfYear % 6236) + 1;
  }

  void _refreshDailyVerseInBackground() {
    _fetchAndCacheDailyVerse().then((_) {}).catchError((Object e) {
      AppLogger.warning(_tag, 'Background daily verse refresh failed: $e');
    });
  }

  Future<TodayProgressModel> getTodayProgress() async {
    final sessions = await _local.getTodaySessions();
    var minutes = 0;
    var pages = 0;
    var ayahs = 0;

    for (final session in sessions) {
      minutes += session.durationMinutes;
      pages += session.pagesRead;
      ayahs += session.ayahsRead;
    }

    return TodayProgressModel(
      readingMinutes: minutes,
      pagesRead: pages,
      ayahsRead: ayahs,
      sessions: sessions.length,
    );
  }

  Future<StreakModel> getStreak() async {
    return _local.getStreak();
  }

  Future<GoalModel> getDailyGoal() async {
    return _local.getDailyGoal();
  }

  Future<List<RecentReadingModel>> getRecentReading() async {
    final recent = await _local.getRecentReadings();
    return recent.map((e) {
      return RecentReadingModel(
        surahNumber: e['surahNumber'] as int,
        englishName: e['englishName'] as String? ?? '',
        surahName: e['surahName'] as String? ?? '',
        lastReadAt: DateTime.parse(e['lastReadAt'] as String),
        ayahNumber: e['ayahNumber'] as int? ?? 1,
      );
    }).toList();
  }

  Future<void> saveReadingProgress(ReadingProgressModel progress) async {
    await _local.saveReadingProgress(progress);
    await _updateStreak();
  }

  Future<void> _updateStreak() async {
    final streak = await _local.getStreak();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (streak.lastReadDate != null) {
      final lastDate = DateTime(
        streak.lastReadDate!.year,
        streak.lastReadDate!.month,
        streak.lastReadDate!.day,
      );
      if (lastDate == todayDate) return;

      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 1) {
        final newStreak = streak.currentStreak + 1;
        await _local.saveStreak(StreakModel(
          currentStreak: newStreak,
          longestStreak: newStreak > streak.longestStreak
              ? newStreak
              : streak.longestStreak,
          lastReadDate: today,
        ));
        return;
      }
    }

    await _local.saveStreak(StreakModel(
      currentStreak: 1,
      longestStreak: streak.longestStreak > 1 ? streak.longestStreak : 1,
      lastReadDate: today,
    ));
  }

  Future<void> recordSession(ReadingSessionModel session) async {
    await _local.saveSession(session);
    final goal = await _local.getDailyGoal();
    await _local.saveDailyGoal(GoalModel(
      targetAyahs: goal.targetAyahs,
      completedAyahs: goal.completedAyahs + session.ayahsRead,
      type: goal.type,
    ));
  }
}
