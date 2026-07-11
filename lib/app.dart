import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'data/models/app_settings_model.dart';
import 'features/audio/providers/audio_provider.dart';
import 'features/authentication/pages/auth_gate.dart';
import 'features/authentication/providers/auth_provider.dart';
import 'features/home/providers/dashboard_provider.dart';
import 'features/insights/providers/insights_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/profile/providers/settings_provider.dart';
import 'features/reading/providers/reading_provider.dart';
import 'features/search/providers/search_provider.dart';
import 'features/shell/providers/app_shell_provider.dart';
import 'features/tracking/providers/tracking_provider.dart';

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
          create: (_) => AuthProvider(
            authRepository: locator.authRepository,
            syncCoordinator: locator.syncCoordinator,
          ),
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
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            repository: locator.settingsRepository,
            authRepository: locator.authRepository,
            syncCoordinator: locator.syncCoordinator,
          )..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            repository: locator.profileRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioProvider(
            repository: locator.audioRepository,
          )..loadPreferences(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final themeMode = _resolveThemeMode(settings.settings.themeMode);
          final darkTheme = settings.settings.themeMode == AppThemeMode.amoled
              ? AppTheme.amoled
              : AppTheme.dark;

          return MaterialApp(
            title: 'Quran Companion',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: darkTheme,
            themeMode: themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }

  ThemeMode _resolveThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
    }
  }
}
