import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/hive_constants.dart';
import '../../models/app_settings_model.dart';
import '../../models/user_profile_model.dart';

/// Local storage for user profile and app settings.
class ProfileLocalDataSource {
  Future<void> init() async {
    await Future.wait([
      Hive.openBox(HiveConstants.profileBox),
      Hive.openBox(HiveConstants.appSettingsBox),
    ]);
  }

  Box get _profileBox => Hive.box(HiveConstants.profileBox);
  Box get _settingsBox => Hive.box(HiveConstants.appSettingsBox);

  Future<UserProfileModel> getProfile() async {
    final map = _profileBox.get('user') as Map?;
    if (map == null) {
      return UserProfileModel(joinDate: DateTime.now());
    }
    return UserProfileModel.fromMap(map);
  }

  Future<void> saveProfile(UserProfileModel profile) async {
    await _profileBox.put('user', profile.toMap());
  }

  Future<AppSettingsModel> getSettings() async {
    final map = _settingsBox.get('settings') as Map?;
    if (map == null) return const AppSettingsModel();
    return AppSettingsModel.fromMap(map);
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    await _settingsBox.put('settings', settings.toMap());
  }
}
