import 'package:flutter/foundation.dart';

import '../../../data/models/app_notification_model.dart';
import '../../../data/models/notification_preferences_model.dart';
import '../../../data/repositories/notification_repository.dart';

enum NotificationStatus { initial, loading, loaded, error }

/// View model for in-app notifications and reminder preferences.
class NotificationProvider extends ChangeNotifier {
  NotificationProvider({required NotificationRepository repository})
      : _repository = repository;

  final NotificationRepository _repository;

  NotificationStatus _status = NotificationStatus.initial;
  String? _errorMessage;

  List<AppNotificationModel> _notifications = [];
  NotificationPreferencesModel _preferences =
      const NotificationPreferencesModel();
  int _unreadCount = 0;

  NotificationStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<AppNotificationModel> get notifications => _notifications;
  NotificationPreferencesModel get preferences => _preferences;
  int get unreadCount => _unreadCount;

  List<AppNotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  Future<void> loadNotifications({bool sync = true}) async {
    if (_status == NotificationStatus.loading) return;

    _status = NotificationStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _preferences = await _repository.getPreferences();
      if (sync) {
        _notifications = await _repository.syncNotifications();
      } else {
        _notifications = await _repository.getNotifications();
      }
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _status = NotificationStatus.loaded;
    } catch (_) {
      _errorMessage = 'Unable to load notifications.';
      _status = NotificationStatus.error;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadNotifications();

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    _notifications = _notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> dismiss(String id) async {
    await _repository.dismiss(id);
    _notifications = _notifications.where((n) => n.id != id).toList();
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  Future<void> updatePreferences(NotificationPreferencesModel prefs) async {
    _preferences = prefs;
    await _repository.savePreferences(prefs);
    notifyListeners();
    await loadNotifications();
  }

  Future<void> toggleEnabled(bool enabled) async {
    await updatePreferences(_preferences.copyWith(enabled: enabled));
  }

  Future<void> setSchedule(NotificationSchedule schedule) async {
    await updatePreferences(_preferences.copyWith(schedule: schedule));
  }

  Future<void> setCustomTime(int hour, int minute) async {
    await updatePreferences(
      _preferences.copyWith(
        schedule: NotificationSchedule.custom,
        customHour: hour,
        customMinute: minute,
      ),
    );
  }
}
