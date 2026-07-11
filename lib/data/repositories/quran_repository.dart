import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/utils/logger.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../datasources/remote/quran_remote_datasource.dart';
import '../models/ayah_model.dart';
import '../models/surah_model.dart';
import '../models/surah_reading_model.dart';

/// Repository for Quran content with cache-first strategy.
class QuranRepository {
  QuranRepository({
    required HiveLocalDataSource local,
    required QuranRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final HiveLocalDataSource _local;
  final QuranRemoteDataSource _remote;
  static const _tag = 'QuranRepository';

  Future<List<SurahModel>> getSurahList({bool refresh = false}) async {
    if (!refresh) {
      final cached = await _local.getSurahs();
      if (cached.isNotEmpty) {
        _refreshSurahListInBackground();
        return cached;
      }
    }

    return _fetchAndCacheSurahList();
  }

  Future<List<SurahModel>> _fetchAndCacheSurahList() async {
    try {
      final surahs = await _remote.fetchSurahList();
      await _local.saveSurahs(surahs);
      return surahs;
    } on AppException {
      final cached = await _local.getSurahs();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  void _refreshSurahListInBackground() {
    _fetchAndCacheSurahList().catchError((Object e) {
      AppLogger.warning(_tag, 'Background surah list refresh failed: $e');
      return <SurahModel>[];
    });
  }

  Future<List<AyahModel>> getSurahAyahs(
    int surahNumber, {
    bool refresh = false,
  }) async {
    if (!refresh) {
      final cached = await _local.getSurahAyahs(surahNumber);
      if (cached.isNotEmpty) {
        _refreshSurahAyahsInBackground(surahNumber);
        return cached;
      }
    }

    return _fetchAndCacheSurahAyahs(surahNumber);
  }

  Future<List<AyahModel>> _fetchAndCacheSurahAyahs(int surahNumber) async {
    try {
      final ayahs = await _remote.fetchSurahAyahs(surahNumber);
      await _local.saveSurahAyahs(surahNumber, ayahs);
      return ayahs;
    } on AppException {
      final cached = await _local.getSurahAyahs(surahNumber);
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  void _refreshSurahAyahsInBackground(int surahNumber) {
    _fetchAndCacheSurahAyahs(surahNumber).catchError((Object e) {
      AppLogger.warning(_tag, 'Background ayah refresh failed: $e');
      return <AyahModel>[];
    });
  }

  Future<AyahModel> getRandomAyah() async {
    final ayah = await _remote.fetchRandomAyah();
    await _local.saveAyah(ayah);
    return ayah;
  }

  Future<AyahModel> getAyahWithTranslations(int ayahNumber) async {
    final cached = await _local.getAyah(ayahNumber);
    if (cached != null &&
        cached.englishText != null &&
        cached.banglaTransliteration != null &&
        cached.banglaTranslation != null &&
        cached.text.isNotEmpty) {
      _refreshAyahInBackground(ayahNumber);
      return cached;
    }

    return _fetchAndCacheAyah(ayahNumber);
  }

  Future<AyahModel> _fetchAndCacheAyah(int ayahNumber) async {
    try {
      final ayah = await _remote.fetchAyahWithEditions(
        ayahNumber,
        ApiConstants.surahReadingEditions,
      );
      await _local.saveAyah(ayah);
      return ayah;
    } on AppException {
      final cached = await _local.getAyah(ayahNumber);
      if (cached != null) return cached;
      rethrow;
    }
  }

  void _refreshAyahInBackground(int ayahNumber) {
    _fetchAndCacheAyah(ayahNumber).catchError((Object e) {
      AppLogger.warning(_tag, 'Background ayah refresh failed: $e');
      return AyahModel(
        number: ayahNumber,
        text: '',
        numberInSurah: 0,
        surahNumber: 0,
      );
    });
  }

  /// Returns a surah with ayahs merged across Arabic, English, and Bangla.
  Future<SurahReadingModel> getSurah(int surahNumber, {bool refresh = false}) async {
    if (!refresh) {
      final cachedAyahs = await _local.getSurahAyahs(surahNumber);
      final hasTranslations = cachedAyahs.isNotEmpty &&
          cachedAyahs.first.englishText != null &&
          cachedAyahs.first.banglaTransliteration != null &&
          cachedAyahs.first.banglaTranslation != null;
      if (cachedAyahs.isNotEmpty && hasTranslations) {
        _refreshSurahWithTranslationsInBackground(surahNumber);
        final surah = await _resolveSurahMeta(surahNumber);
        return SurahReadingModel(surah: surah, ayahs: cachedAyahs);
      }
    }

    return _fetchAndCacheSurahWithTranslations(surahNumber);
  }

  Future<SurahReadingModel> _fetchAndCacheSurahWithTranslations(
    int surahNumber,
  ) async {
    try {
      final ayahs = await _remote.fetchSurahWithEditions(
        surahNumber,
        ApiConstants.surahReadingEditions,
      );
      await _local.saveSurahAyahs(surahNumber, ayahs);
      final surah = await _resolveSurahMeta(surahNumber);
      return SurahReadingModel(surah: surah, ayahs: ayahs);
    } on AppException {
      final cached = await _local.getSurahAyahs(surahNumber);
      if (cached.isNotEmpty) {
        final surah = await _resolveSurahMeta(surahNumber);
        return SurahReadingModel(surah: surah, ayahs: cached);
      }
      rethrow;
    }
  }

  Future<SurahModel> _resolveSurahMeta(int surahNumber) async {
    final cached = await _local.getSurah(surahNumber);
    if (cached != null) return cached;

    final list = await getSurahList();
    return list.firstWhere((s) => s.number == surahNumber);
  }

  void _refreshSurahWithTranslationsInBackground(int surahNumber) {
    _fetchAndCacheSurahWithTranslations(surahNumber).catchError((Object e) {
      AppLogger.warning(_tag, 'Background surah refresh failed: $e');
      return SurahReadingModel(
        surah: SurahModel(
          number: surahNumber,
          name: '',
          englishName: '',
          englishNameTranslation: '',
          numberOfAyahs: 0,
          revelationType: '',
        ),
        ayahs: [],
      );
    });
  }

  /// Force-downloads and caches a full surah with translations.
  Future<SurahReadingModel> downloadSurah(int surahNumber) async {
    return _fetchAndCacheSurahWithTranslations(surahNumber);
  }
}
