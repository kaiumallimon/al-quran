import '../../../core/utils/juz_helper.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../datasources/local/profile_local_datasource.dart';
import '../models/reading_session_model.dart';
import '../models/surah_model.dart';
import '../models/user_profile_model.dart';
import 'dashboard_repository.dart';
import 'tracking_repository.dart';

/// Repository for user profile and aggregated profile statistics.
class ProfileRepository {
  ProfileRepository({
    required ProfileLocalDataSource local,
    required DashboardRepository dashboardRepository,
    required TrackingRepository trackingRepository,
    required HiveLocalDataSource hiveLocal,
  })  : _local = local,
        _dashboard = dashboardRepository,
        _tracking = trackingRepository,
        _hive = hiveLocal;

  final ProfileLocalDataSource _local;
  final DashboardRepository _dashboard;
  final TrackingRepository _tracking;
  final HiveLocalDataSource _hive;

  Future<UserProfileModel> getProfile() async {
    final profile = await _local.getProfile();
    if (profile.joinDate == null) {
      final updated = profile.copyWith(joinDate: DateTime.now());
      await saveProfile(updated);
      return updated;
    }
    return profile;
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
    final profile = UserProfileModel(
      displayName: 'Guest Reader',
      authProvider: AuthProvider.anonymous,
      joinDate: DateTime.now(),
    );
    await saveProfile(profile);
    return profile;
  }

  Future<UserProfileModel> signInWithGoogle() async {
    final profile = UserProfileModel(
      displayName: 'Google User',
      email: 'user@gmail.com',
      authProvider: AuthProvider.google,
      joinDate: DateTime.now(),
    );
    await saveProfile(profile);
    return profile;
  }

  Future<UserProfileModel> signInWithApple() async {
    final profile = UserProfileModel(
      displayName: 'Apple User',
      authProvider: AuthProvider.apple,
      joinDate: DateTime.now(),
    );
    await saveProfile(profile);
    return profile;
  }

  Future<void> signOut() async {
    await saveProfile(
      UserProfileModel(joinDate: DateTime.now()),
    );
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
