import '../datasources/local/hive_local_datasource.dart';
import '../models/reading_preferences_model.dart';
import '../models/reading_progress_model.dart';
import '../models/surah_reading_model.dart';
import 'dashboard_repository.dart';
import 'quran_repository.dart';

/// Repository for reading screen operations.
class ReadingRepository {
  ReadingRepository({
    required HiveLocalDataSource local,
    required QuranRepository quranRepository,
    required DashboardRepository dashboardRepository,
  })  : _local = local,
        _quran = quranRepository,
        _dashboard = dashboardRepository;

  final HiveLocalDataSource _local;
  final QuranRepository _quran;
  final DashboardRepository _dashboard;

  Future<SurahReadingModel> getSurah(int number, {bool refresh = false}) {
    return _quran.getSurah(number, refresh: refresh);
  }

  Future<SurahReadingModel> downloadSurah(int number) {
    return _quran.downloadSurah(number);
  }

  Future<ReadingProgressModel?> restoreReadingProgress() {
    return _local.getReadingProgress();
  }

  Future<void> saveReadingProgress(ReadingProgressModel progress) {
    return _dashboard.saveReadingProgress(progress);
  }

  Future<int?> getScrollAyah(int surahNumber) {
    return _local.getScrollAyah(surahNumber);
  }

  Future<void> saveScrollAyah(int surahNumber, int ayahNumber) {
    return _local.saveScrollAyah(surahNumber, ayahNumber);
  }

  Future<ReadingPreferencesModel> getReadingPreferences() async {
    final map = await _local.getReadingPreferencesMap();
    if (map == null) return const ReadingPreferencesModel();
    return ReadingPreferencesModel.fromMap(map);
  }

  Future<void> saveReadingPreferences(ReadingPreferencesModel prefs) {
    return _local.saveReadingPreferencesMap(prefs.toMap());
  }
}
