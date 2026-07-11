import '../../../core/utils/juz_helper.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../datasources/local/profile_local_datasource.dart';
import '../models/reading_session_model.dart';
import '../models/surah_model.dart';
import '../models/user_profile_model.dart';
import 'auth_repository.dart';
import 'dashboard_repository.dart';
import 'sync_repository.dart';
import 'tracking_repository.dart';

/// Repository for user profile, statistics, and account actions.
class ProfileRepository {
  ProfileRepository({
    required ProfileLocalDataSource local,
    required DashboardRepository dashboardRepository,
    required TrackingRepository trackingRepository,
    required HiveLocalDataSource hiveLocal,
    required AuthRepository authRepository,
    required SyncRepository syncRepository,
  })  : _local = local,
        _dashboard = dashboardRepository,
        _tracking = trackingRepository,
        _hive = hiveLocal,
        _auth = authRepository,
        _sync = syncRepository;

  final ProfileLocalDataSource _local;
  final DashboardRepository _dashboard;
  final TrackingRepository _tracking;
  final HiveLocalDataSource _hive;
  final AuthRepository _auth;
  final SyncRepository _sync;

  Future<UserProfileModel> getProfile() async {
    if (_auth.isSignedIn) {
      return _auth.refreshProfileFromAuth();
    }
    return _local.getProfile();
  }

  Future<void> saveProfile(UserProfileModel profile) {
    return _local.saveProfile(profile);
  }

  Future<ProfileStatsModel> getStats() async {
    final streak = await _dashboard.getStreak();
    final goals = await _tracking.getGoals();
    final sessions = await _hive.getAllSessions();
    final surahs = await _hive.getSurahs();

    return ProfileStatsModel(
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      completedSurahs: await _countCompletedSurahs(surahs),
      completedJuz: _countCompletedJuz(sessions),
      activeGoals: goals.where((g) => !g.isComplete).length,
      totalAyahsRead: _sumAyahs(sessions),
      totalReadingMinutes: _sumMinutes(sessions),
    );
  }

  Future<UserProfileModel> signInAnonymously() async {
    final profile = await _auth.signInAnonymously();
    await _syncAfterSignIn();
    return profile;
  }

  Future<UserProfileModel> signInWithGoogle() async {
    final profile = await _auth.signInWithGoogle();
    await _syncAfterSignIn();
    return profile;
  }

  Future<UserProfileModel> signInWithApple() async {
    final profile = await _auth.signInWithApple();
    await _syncAfterSignIn();
    return profile;
  }

  Future<UserProfileModel> signOut() async {
    return _auth.signOut();
  }

  Future<void> syncNow() async {
    final uid = _auth.currentUid;
    if (uid == null) return;

    final settings = await _local.getSettings();
    await _sync.syncAll(uid: uid, syncEnabled: settings.syncEnabled);
  }

  DateTime? get lastSyncedAt => _sync.lastSyncedAt;
  bool get isSyncing => _sync.isSyncing;

  Future<void> _syncAfterSignIn() async {
    final uid = _auth.currentUid;
    if (uid == null) return;

    final settings = await _local.getSettings();
    if (!settings.syncEnabled) return;

    try {
      await _sync.syncAll(uid: uid, syncEnabled: true);
    } catch (_) {
      // Local data remains authoritative; sync retries later.
    }
  }

  Future<int> _countCompletedSurahs(List<SurahModel> surahs) async {
    var completed = 0;
    for (final surah in surahs) {
      final scrollAyah = await _hive.getScrollAyah(surah.number);
      if (scrollAyah != null && scrollAyah >= surah.numberOfAyahs) {
        completed++;
      }
    }
    return completed;
  }

  int _countCompletedJuz(List<ReadingSessionModel> sessions) {
    if (sessions.isEmpty) return 0;

    final maxPage = sessions
        .map((session) => session.pagesRead)
        .fold<int>(0, (max, pages) => pages > max ? pages : max);

    if (maxPage <= 0) return 0;
    return JuzHelper.juzForPage(maxPage);
  }

  int _sumAyahs(List<ReadingSessionModel> sessions) {
    return sessions.fold(0, (sum, session) => sum + session.ayahsRead);
  }

  int _sumMinutes(List<ReadingSessionModel> sessions) {
    return sessions.fold(0, (sum, session) => sum + session.durationMinutes);
  }
}
