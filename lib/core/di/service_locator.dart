import '../../data/datasources/local/hive_local_datasource.dart';
import '../../data/datasources/local/tracking_local_datasource.dart';
import '../../data/datasources/remote/quran_api_client.dart';
import '../../data/datasources/remote/quran_remote_datasource.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/insights_repository.dart';
import '../../data/repositories/quran_repository.dart';
import '../../data/repositories/reading_repository.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/repositories/tracking_repository.dart';

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

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

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

    _initialized = true;
  }

  void dispose() {
    apiClient.dispose();
  }
}
