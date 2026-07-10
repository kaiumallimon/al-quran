import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/hive_constants.dart';
import '../../models/app_notification_model.dart';
import '../../models/notification_preferences_model.dart';

/// Local Hive storage for in-app notifications and preferences.
class NotificationLocalDataSource {
  static const _preferencesKey = 'notification_preferences';

  Future<void> init() async {
    await Hive.openBox(HiveConstants.notificationsBox);
  }

  Box get _box => Hive.box(HiveConstants.notificationsBox);

  String generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<List<AppNotificationModel>> getAll() async {
    return _box.values
        .where((e) => (e as Map)['id'] != null)
        .map((e) => AppNotificationModel.fromMap(e as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<int> getUnreadCount() async {
    final all = await getAll();
    return all.where((n) => !n.isRead).length;
  }

  Future<bool> existsByDedupeKey(String dedupeKey) async {
    return _box.values.any((e) {
      final map = e as Map;
      return map['dedupeKey'] == dedupeKey;
    });
  }

  Future<AppNotificationModel> save(AppNotificationModel notification) async {
    await _box.put(notification.id, notification.toMap());
    return notification;
  }

  Future<void> markAsRead(String id) async {
    final map = _box.get(id) as Map?;
    if (map == null) return;
    final notification = AppNotificationModel.fromMap(map);
    await _box.put(id, notification.copyWith(isRead: true).toMap());
  }

  Future<void> markAllAsRead() async {
    for (final key in _box.keys) {
      if (key == _preferencesKey) continue;
      final map = _box.get(key) as Map?;
      if (map == null) continue;
      final notification = AppNotificationModel.fromMap(map);
      if (!notification.isRead) {
        await _box.put(key, notification.copyWith(isRead: true).toMap());
      }
    }
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    final prefs = await getPreferences();
    await _box.clear();
    await savePreferences(prefs);
  }

  Future<NotificationPreferencesModel> getPreferences() async {
    final map = _box.get(_preferencesKey) as Map?;
    if (map == null) return const NotificationPreferencesModel();
    return NotificationPreferencesModel.fromMap(map);
  }

  Future<void> savePreferences(NotificationPreferencesModel preferences) async {
    await _box.put(_preferencesKey, preferences.toMap());
  }
}
