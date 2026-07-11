import '../../core/constants/firestore_constants.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../datasources/local/profile_local_datasource.dart';
import '../datasources/local/sync_local_datasource.dart';
import '../datasources/local/tracking_local_datasource.dart';
import '../datasources/remote/firestore_sync_datasource.dart';
import '../models/app_settings_model.dart';
import '../models/bookmark_model.dart';
import '../models/dashboard_model.dart';
import '../models/favorite_model.dart';
import '../models/milestone_model.dart';
import '../models/note_model.dart';
import '../models/reading_progress_model.dart';
import '../models/reading_session_model.dart';
import '../models/reflection_model.dart';
import '../models/tracking_goal_model.dart';
import '../models/user_profile_model.dart';

enum SyncStatus { idle, syncing, success, error }

/// Local-first cloud synchronization via Firestore.
class SyncRepository {
  SyncRepository({
    required FirestoreSyncDataSource remote,
    required SyncLocalDataSource syncLocal,
    required ProfileLocalDataSource profileLocal,
    required TrackingLocalDataSource trackingLocal,
    required HiveLocalDataSource hiveLocal,
  })  : _remote = remote,
        _syncLocal = syncLocal,
        _profileLocal = profileLocal,
        _trackingLocal = trackingLocal,
        _hiveLocal = hiveLocal;

  final FirestoreSyncDataSource _remote;
  final SyncLocalDataSource _syncLocal;
  final ProfileLocalDataSource _profileLocal;
  final TrackingLocalDataSource _trackingLocal;
  final HiveLocalDataSource _hiveLocal;

  SyncStatus _status = SyncStatus.idle;
  String? _errorMessage;

  SyncStatus get status => _status;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncedAt => _syncLocal.lastSyncedAt;
  bool get isSyncing => _syncLocal.isSyncing;

  Future<void> syncAll({
    required String uid,
    required bool syncEnabled,
  }) async {
    if (!syncEnabled || _syncLocal.isSyncing) return;

    _status = SyncStatus.syncing;
    _errorMessage = null;
    await _syncLocal.setSyncing(true);

    try {
      await _pushLocal(uid);
      await _pullRemote(uid);
      await _syncLocal.setLastSyncedAt(DateTime.now());
      await _remote.setSyncMeta(
        uid: uid,
        meta: {'lastSyncedAt': DateTime.now().toIso8601String()},
      );
      _status = SyncStatus.success;
    } catch (_) {
      _errorMessage = 'Cloud sync failed. Your local data is still safe.';
      _status = SyncStatus.error;
      throw const SyncException(
        'Cloud sync failed. Your local data is still safe.',
      );
    } finally {
      await _syncLocal.setSyncing(false);
    }
  }

  Future<void> _pushLocal(String uid) async {
    final profile = await _profileLocal.getProfile();
    final settings = await _profileLocal.getSettings();
    final progress = await _hiveLocal.getReadingProgress();
    final streak = await _hiveLocal.getStreak();
    final dailyGoal = await _hiveLocal.getDailyGoal();

    await _remote.setDocument(
      uid: uid,
      docId: FirestoreConstants.profileDoc,
      data: profile.toMap(),
    );
    await _remote.setDocument(
      uid: uid,
      docId: FirestoreConstants.settingsDoc,
      data: settings.toMap(),
    );
    if (progress != null) {
      await _remote.setDocument(
        uid: uid,
        docId: FirestoreConstants.readingProgressDoc,
        data: progress.toMap(),
      );
    }
    await _remote.setDocument(
      uid: uid,
      docId: FirestoreConstants.streakDoc,
      data: streak.toMap(),
    );
    await _remote.setDocument(
      uid: uid,
      docId: FirestoreConstants.dailyGoalDoc,
      data: dailyGoal.toMap(),
    );

    await _pushCollection(
      uid: uid,
      collection: FirestoreConstants.bookmarksCollection,
      items: (await _trackingLocal.getBookmarks())
          .map((item) => item.toMap())
          .toList(),
    );
    await _pushCollection(
      uid: uid,
      collection: FirestoreConstants.favoritesCollection,
      items: (await _trackingLocal.getFavorites())
          .map((item) => item.toMap())
          .toList(),
    );
    await _pushCollection(
      uid: uid,
      collection: FirestoreConstants.notesCollection,
      items: (await _trackingLocal.getNotes())
          .map((item) => item.toMap())
          .toList(),
    );
    await _pushCollection(
      uid: uid,
      collection: FirestoreConstants.reflectionsCollection,
      items: (await _trackingLocal.getReflections())
          .map((item) => item.toMap())
          .toList(),
    );
    await _pushCollection(
      uid: uid,
      collection: FirestoreConstants.goalsCollection,
      items: (await _trackingLocal.getGoals())
          .map((item) => item.toMap())
          .toList(),
    );
    await _pushCollection(
      uid: uid,
      collection: FirestoreConstants.sessionsCollection,
      items: (await _trackingLocal.getAllSessions())
          .map((item) => item.toMap())
          .toList(),
    );
    await _pushCollection(
      uid: uid,
      collection: FirestoreConstants.milestonesCollection,
      items: (await _trackingLocal.getMilestones())
          .map((item) => item.toMap())
          .toList(),
    );

    final scrollPositions = await _hiveLocal.getAllScrollPositions();
    for (final entry in scrollPositions.entries) {
      await _remote.upsertCollectionItem(
        uid: uid,
        collection: FirestoreConstants.scrollPositionsCollection,
        id: '${entry.key}',
        data: {
          'surahNumber': entry.key,
          'ayahNumber': entry.value,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  Future<void> _pullRemote(String uid) async {
    await _mergeSingleDocument<UserProfileModel>(
      uid: uid,
      docId: FirestoreConstants.profileDoc,
      readLocal: _profileLocal.getProfile,
      saveLocal: _profileLocal.saveProfile,
      fromMap: UserProfileModel.fromMap,
      toMap: (value) => value.toMap(),
    );

    await _mergeSingleDocument<AppSettingsModel>(
      uid: uid,
      docId: FirestoreConstants.settingsDoc,
      readLocal: _profileLocal.getSettings,
      saveLocal: _profileLocal.saveSettings,
      fromMap: AppSettingsModel.fromMap,
      toMap: (value) => value.toMap(),
    );

    await _mergeSingleDocument<ReadingProgressModel>(
      uid: uid,
      docId: FirestoreConstants.readingProgressDoc,
      readLocal: () async =>
          (await _hiveLocal.getReadingProgress()) ??
          ReadingProgressModel(
            surahNumber: 1,
            ayahNumber: 1,
            page: 1,
            lastReadAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
      saveLocal: _hiveLocal.saveReadingProgress,
      fromMap: ReadingProgressModel.fromMap,
      toMap: (value) => value.toMap(),
      optional: true,
    );

    await _mergeSingleDocument<StreakModel>(
      uid: uid,
      docId: FirestoreConstants.streakDoc,
      readLocal: _hiveLocal.getStreak,
      saveLocal: _hiveLocal.saveStreak,
      fromMap: StreakModel.fromMap,
      toMap: (value) => value.toMap(),
    );

    await _mergeSingleDocument<GoalModel>(
      uid: uid,
      docId: FirestoreConstants.dailyGoalDoc,
      readLocal: _hiveLocal.getDailyGoal,
      saveLocal: _hiveLocal.saveDailyGoal,
      fromMap: GoalModel.fromMap,
      toMap: (value) => value.toMap(),
    );

    await _mergeCollection<BookmarkModel>(
      uid: uid,
      collection: FirestoreConstants.bookmarksCollection,
      loadLocal: _trackingLocal.getBookmarks,
      saveLocal: _trackingLocal.addBookmark,
      updateLocal: _trackingLocal.updateBookmark,
      fromMap: BookmarkModel.fromMap,
      idFor: (item) => item.id,
    );
    await _mergeCollection<FavoriteModel>(
      uid: uid,
      collection: FirestoreConstants.favoritesCollection,
      loadLocal: _trackingLocal.getFavorites,
      saveLocal: _trackingLocal.addFavorite,
      fromMap: FavoriteModel.fromMap,
      idFor: (item) => item.id,
    );
    await _mergeCollection<NoteModel>(
      uid: uid,
      collection: FirestoreConstants.notesCollection,
      loadLocal: _trackingLocal.getNotes,
      saveLocal: _trackingLocal.saveNote,
      fromMap: NoteModel.fromMap,
      idFor: (item) => item.id,
    );
    await _mergeCollection<ReflectionModel>(
      uid: uid,
      collection: FirestoreConstants.reflectionsCollection,
      loadLocal: _trackingLocal.getReflections,
      saveLocal: _trackingLocal.saveReflection,
      fromMap: ReflectionModel.fromMap,
      idFor: (item) => item.id,
    );
    await _mergeCollection<TrackingGoalModel>(
      uid: uid,
      collection: FirestoreConstants.goalsCollection,
      loadLocal: _trackingLocal.getGoals,
      saveLocal: _trackingLocal.saveGoal,
      fromMap: TrackingGoalModel.fromMap,
      idFor: (item) => item.id,
    );
    await _mergeCollection<ReadingSessionModel>(
      uid: uid,
      collection: FirestoreConstants.sessionsCollection,
      loadLocal: _trackingLocal.getAllSessions,
      saveLocal: _trackingLocal.saveSession,
      fromMap: ReadingSessionModel.fromMap,
      idFor: (item) => item.id,
    );
    await _mergeCollection<MilestoneModel>(
      uid: uid,
      collection: FirestoreConstants.milestonesCollection,
      loadLocal: _trackingLocal.getMilestones,
      saveLocal: (item) async {
        await _trackingLocal.awardMilestone(item);
      },
      fromMap: MilestoneModel.fromMap,
      idFor: (item) => item.id,
    );

    final remoteScroll = await _remote.getCollection(
      uid: uid,
      collection: FirestoreConstants.scrollPositionsCollection,
    );
    final localScroll = await _hiveLocal.getAllScrollPositions();
    for (final entry in remoteScroll.entries) {
      final surahNumber = entry.value['surahNumber'] as int?;
      final ayahNumber = entry.value['ayahNumber'] as int?;
      if (surahNumber == null || ayahNumber == null) continue;

      final remoteUpdated = _recordUpdatedAt(entry.value);
      final localAyah = localScroll[surahNumber];
      if (localAyah == null || remoteUpdated.isAfter(DateTime.now())) {
        await _hiveLocal.saveScrollAyah(surahNumber, ayahNumber);
      }
    }
  }

  Future<void> _pushCollection({
    required String uid,
    required String collection,
    required List<Map<String, dynamic>> items,
  }) async {
    for (final item in items) {
      final id = item['id'] as String?;
      if (id == null) continue;
      await _remote.upsertCollectionItem(
        uid: uid,
        collection: collection,
        id: id,
        data: item,
      );
    }
  }

  Future<void> _mergeSingleDocument<T>({
    required String uid,
    required String docId,
    required Future<T> Function() readLocal,
    required Future<void> Function(T value) saveLocal,
    required T Function(Map<dynamic, dynamic> map) fromMap,
    required Map<String, dynamic> Function(T value) toMap,
    bool optional = false,
  }) async {
    final remoteMap = await _remote.getDocument(uid: uid, docId: docId);
    if (remoteMap == null) {
      if (!optional) {
        await _remote.setDocument(
          uid: uid,
          docId: docId,
          data: toMap(await readLocal()),
        );
      }
      return;
    }

    final localValue = await readLocal();
    final localMap = toMap(localValue);
    final remoteUpdated = _recordUpdatedAt(remoteMap);
    final localUpdated = _recordUpdatedAt(localMap);

    if (remoteUpdated.isAfter(localUpdated)) {
      await saveLocal(fromMap(remoteMap));
      return;
    }

    if (localUpdated.isAfter(remoteUpdated)) {
      await _remote.setDocument(
        uid: uid,
        docId: docId,
        data: localMap,
      );
    }
  }

  Future<void> _mergeCollection<T>({
    required String uid,
    required String collection,
    required Future<List<T>> Function() loadLocal,
    required Future<void> Function(T item) saveLocal,
    Future<void> Function(T item)? updateLocal,
    required T Function(Map<dynamic, dynamic> map) fromMap,
    required String Function(T item) idFor,
  }) async {
    final localItems = await loadLocal();
    final localById = {
      for (final item in localItems) idFor(item): item,
    };
    final remoteItems = await _remote.getCollection(
      uid: uid,
      collection: collection,
    );

    for (final entry in remoteItems.entries) {
      final remoteItem = fromMap(entry.value);
      final localItem = localById[entry.key];
      if (localItem == null) {
        await saveLocal(remoteItem);
        continue;
      }

      final remoteUpdated = _recordUpdatedAt(entry.value);
      final localUpdated = _recordUpdatedAt(_itemMap(localItem));
      if (remoteUpdated.isAfter(localUpdated)) {
        if (updateLocal != null) {
          await updateLocal(remoteItem);
        } else {
          await saveLocal(remoteItem);
        }
      }
    }

    for (final item in localItems) {
      final map = _itemMap(item);
      final remote = remoteItems[idFor(item)];
      if (remote == null) {
        await _remote.upsertCollectionItem(
          uid: uid,
          collection: collection,
          id: idFor(item),
          data: map,
        );
        continue;
      }

      final remoteUpdated = _recordUpdatedAt(remote);
      final localUpdated = _recordUpdatedAt(map);
      if (localUpdated.isAfter(remoteUpdated)) {
        await _remote.upsertCollectionItem(
          uid: uid,
          collection: collection,
          id: idFor(item),
          data: map,
        );
      }
    }
  }

  Map<String, dynamic> _itemMap(Object item) {
    return (item as dynamic).toMap() as Map<String, dynamic>;
  }

  DateTime _recordUpdatedAt(Map<dynamic, dynamic> map) {
    for (final key in [
      'updatedAt',
      'createdAt',
      'startedAt',
      'lastReadAt',
      'achievedAt',
      'lastReadDate',
      'syncedAt',
    ]) {
      final value = map[key];
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      if (value is TimestampLike) {
        return value.toDate();
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

/// Minimal interface for Firestore timestamp values without importing
/// cloud_firestore into model layers.
abstract class TimestampLike {
  DateTime toDate();
}
