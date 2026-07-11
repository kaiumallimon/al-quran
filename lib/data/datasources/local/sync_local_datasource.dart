import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/hive_constants.dart';

/// Local metadata for cloud synchronization.
class SyncLocalDataSource {
  Future<void> init() async {
    await Hive.openBox(HiveConstants.syncMetaBox);
  }

  Box get _box => Hive.box(HiveConstants.syncMetaBox);

  DateTime? get lastSyncedAt {
    final value = _box.get('lastSyncedAt') as String?;
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> setLastSyncedAt(DateTime value) async {
    await _box.put('lastSyncedAt', value.toIso8601String());
  }

  bool get isSyncing => _box.get('isSyncing') == true;

  Future<void> setSyncing(bool value) async {
    await _box.put('isSyncing', value);
  }
}
