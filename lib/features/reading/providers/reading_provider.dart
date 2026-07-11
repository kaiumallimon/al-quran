import 'package:flutter/foundation.dart';

import '../../../data/models/reading_mode.dart';
import '../../../data/models/reading_preferences_model.dart';
import '../../../data/models/reading_progress_model.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/models/surah_reading_model.dart';
import '../../../data/repositories/quran_repository.dart';
import '../../../data/repositories/reading_repository.dart';

enum SurahListStatus { initial, loading, loaded, error }

enum SurahReadingStatus { initial, loading, loaded, error }

/// View model for surah list and reading screen.
class ReadingProvider extends ChangeNotifier {
  ReadingProvider({
    required ReadingRepository readingRepository,
    required QuranRepository quranRepository,
  })  : _readingRepository = readingRepository,
        _quranRepository = quranRepository;

  final ReadingRepository _readingRepository;
  final QuranRepository _quranRepository;

  // Surah list state
  SurahListStatus _listStatus = SurahListStatus.initial;
  List<SurahModel> _surahs = [];
  String _searchQuery = '';
  String? _listError;

  // Reading state
  SurahReadingStatus _readingStatus = SurahReadingStatus.initial;
  SurahReadingModel? _currentSurah;
  String? _readingError;
  int? _highlightedAyah;
  int? _scrollToAyah;
  ReadingPreferencesModel _preferences = const ReadingPreferencesModel();

  SurahListStatus get listStatus => _listStatus;
  List<SurahModel> get surahs => _surahs;
  String get searchQuery => _searchQuery;
  String? get listError => _listError;

  SurahReadingStatus get readingStatus => _readingStatus;
  SurahReadingModel? get currentSurah => _currentSurah;
  String? get readingError => _readingError;
  int? get highlightedAyah => _highlightedAyah;
  int? get scrollToAyah => _scrollToAyah;
  ReadingPreferencesModel get preferences => _preferences;

  List<SurahModel> get filteredSurahs {
    if (_searchQuery.isEmpty) return _surahs;
    final q = _searchQuery.toLowerCase();
    return _surahs.where((s) {
      return s.englishName.toLowerCase().contains(q) ||
          s.englishNameTranslation.toLowerCase().contains(q) ||
          s.name.contains(_searchQuery) ||
          s.number.toString() == _searchQuery;
    }).toList();
  }

  Future<void> loadSurahList() async {
    if (_listStatus == SurahListStatus.loading) return;

    _listStatus = SurahListStatus.loading;
    _listError = null;
    notifyListeners();

    try {
      _surahs = await _quranRepository.getSurahList();
      _listStatus = SurahListStatus.loaded;
    } catch (_) {
      _listError = 'Unable to load surahs. Please try again.';
      _listStatus = SurahListStatus.error;
    }

    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    _preferences = await _readingRepository.getReadingPreferences();
    notifyListeners();
  }

  Future<void> openSurah(int surahNumber, {int? initialAyah}) async {
    _readingStatus = SurahReadingStatus.loading;
    _readingError = null;
    _currentSurah = null;
    _highlightedAyah = initialAyah;
    notifyListeners();

    try {
      await loadPreferences();

      final scrollAyah = initialAyah ??
          await _readingRepository.getScrollAyah(surahNumber);
      _scrollToAyah = scrollAyah;

      _currentSurah = await _readingRepository.getSurah(surahNumber);
      _readingStatus = SurahReadingStatus.loaded;
    } catch (_) {
      _readingError = 'Unable to load surah. Please try again.';
      _readingStatus = SurahReadingStatus.error;
    }

    notifyListeners();
  }

  void clearScrollTarget() {
    _scrollToAyah = null;
    notifyListeners();
  }

  Future<void> updateProgress(int ayahNumberInSurah) async {
    final surah = _currentSurah;
    if (surah == null) return;

    final ayah = surah.ayahs.firstWhere(
      (a) => a.numberInSurah == ayahNumberInSurah,
      orElse: () => surah.ayahs.first,
    );

    await _readingRepository.saveScrollAyah(surah.surah.number, ayahNumberInSurah);

    final progressPercent = ayahNumberInSurah / surah.surah.numberOfAyahs;

    await _readingRepository.saveReadingProgress(ReadingProgressModel(
      surahNumber: surah.surah.number,
      ayahNumber: ayahNumberInSurah,
      page: ayah.page ?? 1,
      lastReadAt: DateTime.now(),
      surahName: surah.surah.name,
      englishName: surah.surah.englishName,
      progressPercent: progressPercent,
    ));
  }

  void setHighlightedAyah(int? ayahNumber) {
    _highlightedAyah = ayahNumber;
    notifyListeners();
  }

  Future<void> updatePreferences(ReadingPreferencesModel prefs) async {
    _preferences = prefs;
    await _readingRepository.saveReadingPreferences(prefs);
    notifyListeners();
  }

  Future<void> setArabicFontSize(double size) async {
    await updatePreferences(_preferences.copyWith(arabicFontSize: size));
  }

  Future<void> setTranslationFontSize(double size) async {
    await updatePreferences(_preferences.copyWith(translationFontSize: size));
  }

  Future<void> toggleTranslations() async {
    await updatePreferences(
      _preferences.copyWith(showTranslations: !_preferences.showTranslations),
    );
  }

  Future<void> setShowTranslations(bool value) async {
    await updatePreferences(_preferences.copyWith(showTranslations: value));
  }

  Future<void> setShowEnglishTranslation(bool value) async {
    await updatePreferences(
      _preferences.copyWith(showEnglishTranslation: value),
    );
  }

  Future<void> setShowTransliteration(bool value) async {
    await updatePreferences(_preferences.copyWith(showTransliteration: value));
  }

  Future<void> setShowBanglaTranslation(bool value) async {
    await updatePreferences(
      _preferences.copyWith(showBanglaTranslation: value),
    );
  }

  Future<void> setReadingMode(ReadingMode mode) async {
    await updatePreferences(_preferences.copyWith(readingMode: mode));
  }

  Future<void> downloadCurrentSurah() async {
    final number = _currentSurah?.surah.number;
    if (number == null) return;

    _currentSurah = await _readingRepository.downloadSurah(number);
    notifyListeners();
  }

  void resetReadingState() {
    _readingStatus = SurahReadingStatus.initial;
    _currentSurah = null;
    _readingError = null;
    _highlightedAyah = null;
    _scrollToAyah = null;
    notifyListeners();
  }
}
