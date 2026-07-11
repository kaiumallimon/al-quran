import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/hive_constants.dart';
import '../../models/ayah_model.dart';
import '../../models/daily_verse_model.dart';
import '../../models/dashboard_model.dart';
import '../../models/reading_progress_model.dart';
import '../../models/reading_session_model.dart';
import '../../models/search_result_model.dart';
import '../../models/surah_model.dart';

/// Local Hive data source for offline-first storage.
class HiveLocalDataSource {
  Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(HiveConstants.surahsBox),
      Hive.openBox(HiveConstants.ayahsBox),
      Hive.openBox(HiveConstants.readingProgressBox),
      Hive.openBox(HiveConstants.readingSessionsBox),
      Hive.openBox(HiveConstants.goalsBox),
      Hive.openBox(HiveConstants.streaksBox),
      Hive.openBox(HiveConstants.dailyVerseBox),
      Hive.openBox(HiveConstants.preferencesBox),
      Hive.openBox(HiveConstants.searchHistoryBox),
    ]);
  }

  Box get _surahsBox => Hive.box(HiveConstants.surahsBox);
  Box get _ayahsBox => Hive.box(HiveConstants.ayahsBox);
  Box get _progressBox => Hive.box(HiveConstants.readingProgressBox);
  Box get _sessionsBox => Hive.box(HiveConstants.readingSessionsBox);
  Box get _goalsBox => Hive.box(HiveConstants.goalsBox);
  Box get _streaksBox => Hive.box(HiveConstants.streaksBox);
  Box get _dailyVerseBox => Hive.box(HiveConstants.dailyVerseBox);
  Box get _preferencesBox => Hive.box(HiveConstants.preferencesBox);
  Box get _searchHistoryBox => Hive.box(HiveConstants.searchHistoryBox);

  // --- Surahs ---

  Future<List<SurahModel>> getSurahs() async {
    final list = _surahsBox.get('list') as List?;
    if (list == null) return [];
    return list
        .map((e) => SurahModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  Future<void> saveSurahs(List<SurahModel> surahs) async {
    await _surahsBox.put('list', surahs.map((s) => s.toMap()).toList());
  }

  Future<SurahModel?> getSurah(int number) async {
    final map = _surahsBox.get('surah_$number') as Map?;
    if (map == null) return null;
    return SurahModel.fromMap(map);
  }

  Future<void> saveSurah(SurahModel surah) async {
    await _surahsBox.put('surah_${surah.number}', surah.toMap());
  }

  // --- Ayahs ---

  Future<List<AyahModel>> getSurahAyahs(int surahNumber) async {
    final list = _ayahsBox.get('surah_$surahNumber') as List?;
    if (list == null) return [];
    return list
        .map((e) => AyahModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  Future<void> saveSurahAyahs(int surahNumber, List<AyahModel> ayahs) async {
    await _ayahsBox.put(
      'surah_$surahNumber',
      ayahs.map((a) => a.toMap()).toList(),
    );
  }

  Future<AyahModel?> getAyah(int number) async {
    final map = _ayahsBox.get('ayah_$number') as Map?;
    if (map == null) return null;
    return AyahModel.fromMap(map);
  }

  Future<void> saveAyah(AyahModel ayah) async {
    await _ayahsBox.put('ayah_${ayah.number}', ayah.toMap());
  }

  // --- Reading Progress ---

  Future<ReadingProgressModel?> getReadingProgress() async {
    final map = _progressBox.get('current') as Map?;
    if (map == null) return null;
    return ReadingProgressModel.fromMap(map);
  }

  Future<void> saveReadingProgress(ReadingProgressModel progress) async {
    await _progressBox.put('current', progress.toMap());
    await _addRecentReading(progress);
  }

  Future<void> _addRecentReading(ReadingProgressModel progress) async {
    final list = (_progressBox.get('recent') as List?) ?? [];
    final entry = {
      'surahNumber': progress.surahNumber,
      'englishName': progress.englishName,
      'surahName': progress.surahName,
      'lastReadAt': progress.lastReadAt.toIso8601String(),
      'ayahNumber': progress.ayahNumber,
    };

    final updated = [
      entry,
      ...list.where((e) {
        final m = e as Map;
        return m['surahNumber'] != progress.surahNumber;
      }),
    ].take(5).toList();

    await _progressBox.put('recent', updated);
  }

  Future<List<Map<dynamic, dynamic>>> getRecentReadings() async {
    return (_progressBox.get('recent') as List?)?.cast<Map>() ?? [];
  }

  // --- Reading Sessions ---

  Future<List<ReadingSessionModel>> getAllSessions() async {
    return _sessionsBox.values
        .map((e) => ReadingSessionModel.fromMap(e as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  Future<List<ReadingSessionModel>> getTodaySessions() async {
    final all = await getAllSessions();

    final today = DateTime.now();
    return all.where((s) {
      return s.startedAt.year == today.year &&
          s.startedAt.month == today.month &&
          s.startedAt.day == today.day;
    }).toList();
  }

  Future<void> saveSession(ReadingSessionModel session) async {
    await _sessionsBox.put(session.id, session.toMap());
  }

  // --- Goals ---

  Future<GoalModel> getDailyGoal() async {
    final map = _goalsBox.get('daily') as Map?;
    if (map == null) {
      return const GoalModel(
        targetAyahs: AppConstants.defaultDailyGoalAyahs,
      );
    }
    return GoalModel.fromMap(map);
  }

  Future<void> saveDailyGoal(GoalModel goal) async {
    await _goalsBox.put('daily', goal.toMap());
  }

  // --- Streaks ---

  Future<StreakModel> getStreak() async {
    final map = _streaksBox.get('current') as Map?;
    if (map == null) return const StreakModel();
    return StreakModel.fromMap(map);
  }

  Future<void> saveStreak(StreakModel streak) async {
    await _streaksBox.put('current', streak.toMap());
  }

  // --- Daily Verse ---

  Future<DailyVerseModel?> getDailyVerse() async {
    final map = _dailyVerseBox.get('current') as Map?;
    if (map == null) return null;
    return DailyVerseModel.fromMap(map);
  }

  Future<void> saveDailyVerse(DailyVerseModel verse) async {
    await _dailyVerseBox.put('current', verse.toMap());
  }

  // --- Preferences ---

  Future<String?> getPreference(String key) async {
    return _preferencesBox.get(key) as String?;
  }

  Future<void> setPreference(String key, dynamic value) async {
    await _preferencesBox.put(key, value);
  }

  Future<bool> get isOnboardingComplete async {
    return _preferencesBox.get('onboarding_complete') == true;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _preferencesBox.put('onboarding_complete', value);
  }

  // --- Reading Preferences ---

  Future<Map<dynamic, dynamic>?> getReadingPreferencesMap() async {
    return _preferencesBox.get('reading_prefs') as Map?;
  }

  Future<void> saveReadingPreferencesMap(Map<String, dynamic> map) async {
    await _preferencesBox.put('reading_prefs', map);
  }

  // --- Scroll Position per Surah ---

  Future<int?> getScrollAyah(int surahNumber) async {
    return _progressBox.get('scroll_$surahNumber') as int?;
  }

  Future<void> saveScrollAyah(int surahNumber, int ayahNumber) async {
    await _progressBox.put('scroll_$surahNumber', ayahNumber);
  }

  Future<Map<int, int>> getAllScrollPositions() async {
    final positions = <int, int>{};
    for (final key in _progressBox.keys) {
      if (key is! String || !key.startsWith('scroll_')) continue;
      final surahNumber = int.tryParse(key.substring(7));
      final ayahNumber = _progressBox.get(key);
      if (surahNumber != null && ayahNumber is int) {
        positions[surahNumber] = ayahNumber;
      }
    }
    return positions;
  }

  // --- Search History ---

  Future<List<String>> getRecentSearches() async {
    final list = _searchHistoryBox.get('recent') as List?;
    if (list == null) return [];
    return list.cast<String>();
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;

    final current = await getRecentSearches();
    final updated = [
      trimmed,
      ...current.where((s) => s.toLowerCase() != trimmed.toLowerCase()),
    ].take(10).toList();

    await _searchHistoryBox.put('recent', updated);
  }

  Future<void> clearSearchHistory() async {
    await _searchHistoryBox.delete('recent');
  }

  /// Searches cached surahs and ayahs locally.
  Future<List<SearchResultModel>> searchLocal(String query) async {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return [];

    final results = <String, SearchResultModel>{};

    // Search surah names
    final surahs = await getSurahs();
    for (final surah in surahs) {
      if (_matchesSurah(surah, q)) {
        results['surah_${surah.number}'] = SearchResultModel(
          surahNumber: surah.number,
          numberInSurah: 1,
          previewText: surah.englishNameTranslation,
          surahEnglishName: surah.englishName,
          surahArabicName: surah.name,
          matchedIn: 'surah_name',
          isLocal: true,
        );
      }
    }

    // Search cached ayahs
    for (final key in _ayahsBox.keys) {
      if (key is! String || !key.startsWith('surah_')) continue;

      final list = _ayahsBox.get(key) as List?;
      if (list == null) continue;

      for (final item in list) {
        final ayah = AyahModel.fromMap(item as Map<dynamic, dynamic>);
        final matchField = _matchAyahField(ayah, q);
        if (matchField == null) continue;

        final resultKey = '${ayah.surahNumber}:${ayah.numberInSurah}';
        if (results.containsKey(resultKey)) continue;

        final surah = surahs.firstWhere(
          (s) => s.number == ayah.surahNumber,
          orElse: () => SurahModel(
            number: ayah.surahNumber,
            name: '',
            englishName: 'Surah ${ayah.surahNumber}',
            englishNameTranslation: '',
            numberOfAyahs: 0,
            revelationType: '',
          ),
        );

        results[resultKey] = SearchResultModel(
          surahNumber: ayah.surahNumber,
          numberInSurah: ayah.numberInSurah,
          globalAyahNumber: ayah.number,
          previewText: _previewForField(ayah, matchField),
          arabicText: ayah.text,
          englishText: ayah.englishText,
          surahEnglishName: surah.englishName,
          surahArabicName: surah.name,
          matchedIn: matchField,
          isLocal: true,
        );
      }
    }

    return results.values.toList();
  }

  bool _matchesSurah(SurahModel surah, String query) {
    return surah.englishName.toLowerCase().contains(query) ||
        surah.englishNameTranslation.toLowerCase().contains(query) ||
        surah.name.contains(query) ||
        surah.number.toString() == query;
  }

  String? _matchAyahField(AyahModel ayah, String query) {
    if (ayah.text.toLowerCase().contains(query)) return 'arabic';
    if (ayah.englishText?.toLowerCase().contains(query) ?? false) {
      return 'english';
    }
    if (ayah.transliteration?.toLowerCase().contains(query) ?? false) {
      return 'bangla';
    }
    if (ayah.banglaTranslation?.toLowerCase().contains(query) ?? false) {
      return 'bangla';
    }
    return null;
  }

  String _previewForField(AyahModel ayah, String field) {
    switch (field) {
      case 'arabic':
        return ayah.text;
      case 'english':
        return ayah.englishText ?? ayah.text;
      case 'bangla':
        return ayah.transliteration ?? ayah.banglaTranslation ?? '';
      default:
        return ayah.text;
    }
  }
}
