import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/home/providers/dashboard_provider.dart';
import 'features/reading/providers/reading_provider.dart';
import 'features/search/providers/search_provider.dart';
import 'features/shell/providers/app_shell_provider.dart';
import 'features/tracking/providers/tracking_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/insights/providers/insights_provider.dart';
import 'features/shell/pages/app_shell.dart';

/// Root application widget.
class QuranCompanionApp extends StatelessWidget {
  const QuranCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locator = ServiceLocator.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(
            dashboardRepository: locator.dashboardRepository,
            quranRepository: locator.quranRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReadingProvider(
            readingRepository: locator.readingRepository,
            quranRepository: locator.quranRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(
            searchRepository: locator.searchRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AppShellProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            repository: locator.notificationRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => InsightsProvider(
            repository: locator.insightsRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TrackingProvider(
            repository: locator.trackingRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Quran Companion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const AppShell(),
      ),
    );
  }
}
