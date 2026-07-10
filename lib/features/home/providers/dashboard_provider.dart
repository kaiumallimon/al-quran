import 'package:flutter/foundation.dart';

import '../../../data/models/daily_verse_model.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/reading_progress_model.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/repositories/quran_repository.dart';

enum DashboardStatus { initial, loading, loaded, error }

/// View model for the home dashboard.
class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    required DashboardRepository dashboardRepository,
    required QuranRepository quranRepository,
  })  : _dashboardRepository = dashboardRepository,
        _quranRepository = quranRepository;

  final DashboardRepository _dashboardRepository;
  final QuranRepository _quranRepository;

  DashboardStatus _status = DashboardStatus.initial;
  DashboardModel? _dashboard;
  String? _errorMessage;

  DashboardStatus get status => _status;
  DashboardModel? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;

  ReadingProgressModel? get continueReading => _dashboard?.continueReading;
  DailyVerseModel? get dailyVerse => _dashboard?.dailyVerse;
  TodayProgressModel get todayProgress =>
      _dashboard?.todayProgress ?? const TodayProgressModel();
  StreakModel get streak => _dashboard?.streak ?? const StreakModel();
  GoalModel get goal =>
      _dashboard?.goal ?? const GoalModel(targetAyahs: 10);
  List<RecentReadingModel> get recentReadings =>
      _dashboard?.recentReadings ?? [];

  Future<void> loadDashboard() async {
    if (_status == DashboardStatus.loading) return;

    _status = DashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _quranRepository.getSurahList();
      _dashboard = await _dashboardRepository.getDashboard();
      _status = DashboardStatus.loaded;
    } catch (e) {
      _errorMessage = 'Unable to load dashboard. Please try again.';
      _status = DashboardStatus.error;
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    _status = DashboardStatus.loading;
    notifyListeners();

    try {
      await _quranRepository.getSurahList(refresh: true);
      _dashboard = await _dashboardRepository.getDashboard();
      _status = DashboardStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Unable to refresh. Please try again.';
      _status = DashboardStatus.error;
    }

    notifyListeners();
  }
}
