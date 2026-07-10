import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../providers/tracking_provider.dart';
import '../widgets/bookmarks_tab.dart';
import '../widgets/goals_tab.dart';
import '../widgets/history_tab.dart';
import '../widgets/notes_tab.dart';
import '../widgets/reflections_tab.dart';

/// Hub for bookmarks, notes, reflections, goals, and history.
class TrackingHubPage extends StatefulWidget {
  const TrackingHubPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<TrackingHubPage> createState() => _TrackingHubPageState();
}

class _TrackingHubPageState extends State<TrackingHubPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journey'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Bookmarks'),
            Tab(text: 'Notes'),
            Tab(text: 'Reflections'),
            Tab(text: 'Goals'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, provider, _) {
          if (provider.status == TrackingStatus.loading) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const [
                SkeletonLoader(height: 80),
                SizedBox(height: AppSpacing.sm),
                SkeletonLoader(height: 80),
              ],
            );
          }

          if (provider.status == TrackingStatus.error) {
            return Center(
              child: ErrorStateWidget(
                message: provider.errorMessage ?? 'Something went wrong',
                onRetry: provider.loadAll,
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: const [
              BookmarksTab(),
              NotesTab(),
              ReflectionsTab(),
              GoalsTab(),
              HistoryTab(),
            ],
          );
        },
      ),
    );
  }
}
