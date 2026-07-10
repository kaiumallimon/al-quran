import '../datasources/local/profile_local_datasource.dart';
import '../models/app_settings_model.dart';

/// Repository for application settings persisted locally.
class SettingsRepository {
  SettingsRepository({required ProfileLocalDataSource local}) : _local = local;

  final ProfileLocalDataSource _local;

  Future<AppSettingsModel> getSettings() => _local.getSettings();

  Future<void> saveSettings(AppSettingsModel settings) {
    return _local.saveSettings(settings);
  }

  Future<void> updateSettings(AppSettingsModel Function(AppSettingsModel) update) async {
    final current = await getSettings();
    await saveSettings(update(current));
  }
}
