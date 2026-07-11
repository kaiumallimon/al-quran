import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../data/datasources/local/audio_local_datasource.dart';
import '../../data/datasources/local/profile_local_datasource.dart';
import '../../data/datasources/local/hive_local_datasource.dart';
import '../../data/datasources/local/notification_local_datasource.dart';
import '../../data/datasources/local/sync_local_datasource.dart';
import '../../data/datasources/local/tracking_local_datasource.dart';
import '../../data/datasources/remote/audio_remote_datasource.dart';
import '../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../data/datasources/remote/firestore_sync_datasource.dart';
import '../../data/datasources/remote/quran_api_client.dart';
import '../../data/datasources/remote/quran_remote_datasource.dart';
import '../../data/repositories/audio_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/insights_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/quran_repository.dart';
import '../../data/repositories/reading_repository.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/sync_repository.dart';
import '../../data/repositories/tracking_repository.dart';
import '../../firebase_options.dart';
import '../services/quran_audio_handler.dart';
import '../services/sync_coordinator.dart';

/// Central dependency registration for the application.
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  late final HiveLocalDataSource localDataSource;
  late final QuranApiClient apiClient;
  late final QuranRemoteDataSource remoteDataSource;
  late final QuranRepository quranRepository;
  late final DashboardRepository dashboardRepository;
  late final ReadingRepository readingRepository;
  late final SearchRepository searchRepository;
  late final TrackingLocalDataSource trackingLocalDataSource;
  late final TrackingRepository trackingRepository;
  late final InsightsRepository insightsRepository;
  late final NotificationLocalDataSource notificationLocalDataSource;
  late final NotificationRepository notificationRepository;
  late final AudioLocalDataSource audioLocalDataSource;
  late final AudioRemoteDataSource audioRemoteDataSource;
  late final QuranAudioHandler audioHandler;
  late final AudioRepository audioRepository;
  late final ProfileLocalDataSource profileLocalDataSource;
  late final SyncLocalDataSource syncLocalDataSource;
  late final FirebaseAuthDataSource firebaseAuthDataSource;
  late final FirestoreSyncDataSource firestoreSyncDataSource;
  late final AuthRepository authRepository;
  late final SyncRepository syncRepository;
  late final SyncCoordinator syncCoordinator;
  late final ProfileRepository profileRepository;
  late final SettingsRepository settingsRepository;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    localDataSource = HiveLocalDataSource();
    await localDataSource.init();

    apiClient = QuranApiClient();
    remoteDataSource = QuranRemoteDataSource(apiClient);

    quranRepository = QuranRepository(
      local: localDataSource,
      remote: remoteDataSource,
    );

    dashboardRepository = DashboardRepository(
      local: localDataSource,
      quranRepository: quranRepository,
    );

    readingRepository = ReadingRepository(
      local: localDataSource,
      quranRepository: quranRepository,
      dashboardRepository: dashboardRepository,
    );

    searchRepository = SearchRepository(
      local: localDataSource,
      remote: remoteDataSource,
    );

    trackingLocalDataSource = TrackingLocalDataSource();
    await trackingLocalDataSource.init();

    trackingRepository = TrackingRepository(
      trackingLocal: trackingLocalDataSource,
      hiveLocal: localDataSource,
    );

    insightsRepository = InsightsRepository(
      hiveLocal: localDataSource,
      dashboardRepository: dashboardRepository,
      trackingRepository: trackingRepository,
    );

    notificationLocalDataSource = NotificationLocalDataSource();
    await notificationLocalDataSource.init();

    notificationRepository = NotificationRepository(
      local: notificationLocalDataSource,
      dashboardRepository: dashboardRepository,
      insightsRepository: insightsRepository,
      trackingRepository: trackingRepository,
    );

    audioLocalDataSource = AudioLocalDataSource();
    await audioLocalDataSource.init();

    audioRemoteDataSource = AudioRemoteDataSource(apiClient);

    final handler = QuranAudioHandler();
    await AudioService.init(
      builder: () => handler,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.alquran.audio',
        androidNotificationChannelName: 'Quran Recitation',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
    audioHandler = handler;

    audioRepository = AudioRepository(
      local: audioLocalDataSource,
      remote: audioRemoteDataSource,
      handler: audioHandler,
    );

    profileLocalDataSource = ProfileLocalDataSource();
    await profileLocalDataSource.init();

    syncLocalDataSource = SyncLocalDataSource();
    await syncLocalDataSource.init();

    firebaseAuthDataSource = FirebaseAuthDataSource();
    firestoreSyncDataSource = FirestoreSyncDataSource();

    authRepository = AuthRepository(
      remote: firebaseAuthDataSource,
      local: profileLocalDataSource,
    );

    syncRepository = SyncRepository(
      remote: firestoreSyncDataSource,
      syncLocal: syncLocalDataSource,
      profileLocal: profileLocalDataSource,
      trackingLocal: trackingLocalDataSource,
      hiveLocal: localDataSource,
    );

    syncCoordinator = SyncCoordinator(
      authRepository: authRepository,
      syncRepository: syncRepository,
      profileLocal: profileLocalDataSource,
    );
    syncCoordinator.start();
    syncCoordinator.scheduleSync();

    profileRepository = ProfileRepository(
      local: profileLocalDataSource,
      dashboardRepository: dashboardRepository,
      trackingRepository: trackingRepository,
      hiveLocal: localDataSource,
      authRepository: authRepository,
      syncRepository: syncRepository,
    );

    settingsRepository = SettingsRepository(local: profileLocalDataSource);

    _initialized = true;
  }

  void dispose() {
    syncCoordinator.dispose();
    apiClient.dispose();
  }
}
