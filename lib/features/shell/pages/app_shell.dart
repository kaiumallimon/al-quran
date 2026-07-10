import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/pages/home_dashboard_page.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../profile/pages/profile_page.dart';
import '../../reading/pages/surah_list_page.dart';
import '../../search/pages/search_page.dart';
import '../../audio/widgets/mini_audio_player.dart';
import '../providers/app_shell_provider.dart';

/// Main app shell with bottom navigation.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  static const _pages = [
    HomeDashboardPage(),
    SurahListPage(),
    SearchPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationProvider>().loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<AppShellProvider>();

    return Scaffold(
      body: IndexedStack(
        index: shell.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniAudioPlayer(),
          NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (index) {
              context.read<AppShellProvider>().setIndex(index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Read',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
