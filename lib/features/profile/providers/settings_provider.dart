import 'package:flutter/foundation.dart';

import '../../../core/services/sync_coordinator.dart';
import '../../../data/models/app_settings_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/settings_repository.dart';

enum SettingsStatus { initial, loaded }

/// View model for application settings and theme preferences.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required SettingsRepository repository,
    required AuthRepository authRepository,
    required SyncCoordinator syncCoordinator,
  })  : _repository = repository,
        _authRepository = authRepository,
        _syncCoordinator = syncCoordinator;

  final SettingsRepository _repository;
  final AuthRepository _authRepository;
  final SyncCoordinator _syncCoordinator;

  SettingsStatus _status = SettingsStatus.initial;
  AppSettingsModel _settings = const AppSettingsModel();

  SettingsStatus get status => _status;
  AppSettingsModel get settings => _settings;

  Future<void> loadSettings() async {
    _settings = await _repository.getSettings();
    _status = SettingsStatus.loaded;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettingsModel settings) async {
    _settings = settings;
    await _repository.saveSettings(settings);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await updateSettings(_settings.copyWith(themeMode: mode));
  }

  Future<void> toggleKeepScreenAwake(bool value) async {
    await updateSettings(_settings.copyWith(keepScreenAwake: value));
  }

  Future<void> toggleAutoResume(bool value) async {
    await updateSettings(_settings.copyWith(autoResumeReading: value));
  }

  Future<void> toggleAnalytics(bool value) async {
    await updateSettings(_settings.copyWith(analyticsEnabled: value));
  }

  Future<void> toggleCrashReports(bool value) async {
    await updateSettings(_settings.copyWith(crashReportsEnabled: value));
  }

  Future<String?> toggleSync(bool value) async {
    if (value && !_authRepository.isSignedIn) {
      return 'Sign in from your Profile tab to enable cloud sync.';
    }

    await updateSettings(_settings.copyWith(syncEnabled: value));
    if (value) {
      _syncCoordinator.scheduleSync();
    }
    return null;
  }

  Future<void> toggleReduceMotion(bool value) async {
    await updateSettings(_settings.copyWith(reduceMotion: value));
  }

  Future<void> toggleHighContrast(bool value) async {
    await updateSettings(_settings.copyWith(highContrast: value));
  }

  Future<void> toggleDynamicText(bool value) async {
    await updateSettings(_settings.copyWith(dynamicText: value));
  }

  Future<void> toggleRtlPreview(bool value) async {
    await updateSettings(_settings.copyWith(rtlPreview: value));
  }

  Future<void> setArabicFont(String font) async {
    await updateSettings(_settings.copyWith(arabicFont: font));
  }

  Future<void> setReadingWidth(double width) async {
    await updateSettings(_settings.copyWith(readingWidth: width));
  }
}
