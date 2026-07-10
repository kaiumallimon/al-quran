import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/tracking_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../data/models/user_profile_model.dart';
import '../providers/profile_provider.dart';
import '../pages/settings_page.dart';

/// User profile tab with stats and account access.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.status == ProfileStatus.loading &&
              provider.profile == null) {
            return _buildLoading();
          }

          if (provider.status == ProfileStatus.error &&
              provider.profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ErrorStateWidget(
                  message: provider.errorMessage ?? 'Unable to load profile',
                  onRetry: provider.loadProfile,
                ),
              ),
            );
          }

          final profile = provider.profile!;
          final stats = provider.stats;

          return RefreshIndicator(
            onRefresh: provider.loadProfile,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _ProfileHeader(profile: profile),
                const SizedBox(height: AppSpacing.lg),
                if (stats != null) _StatsGrid(stats: stats),
                const SizedBox(height: AppSpacing.lg),
                _AccountSection(profile: profile, provider: provider),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.flag_outlined),
                        title: const Text('Reading goals'),
                        trailing: Text('${stats?.activeGoals ?? 0} active'),
                        onTap: () => TrackingNavigation.openTrackingHub(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(height: 120),
        SizedBox(height: AppSpacing.lg),
        SkeletonLoader(height: 100),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              profile.displayName.isNotEmpty
                  ? profile.displayName[0].toUpperCase()
                  : '?',
              style: AppTypography.headline(context).copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.displayName, style: AppTypography.title(context)),
                if (profile.email != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    profile.email!,
                    style: AppTypography.small(context).copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.isSignedIn
                      ? 'Signed in via ${profile.authProvider.label}'
                      : 'Reading locally — sign in to sync',
                  style: AppTypography.small(context).copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final ProfileStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.6,
      children: [
        _StatCard(label: 'Current streak', value: '${stats.currentStreak} days'),
        _StatCard(label: 'Longest streak', value: '${stats.longestStreak} days'),
        _StatCard(label: 'Completed surahs', value: '${stats.completedSurahs}'),
        _StatCard(label: 'Completed juz', value: '${stats.completedJuz}'),
        _StatCard(label: 'Ayahs read', value: '${stats.totalAyahsRead}'),
        _StatCard(
          label: 'Reading time',
          value: '${stats.totalReadingMinutes} min',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTypography.title(context),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.small(context).copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.profile,
    required this.provider,
  });

  final UserProfileModel profile;
  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text('Account', style: AppTypography.subtitle(context)),
          ),
          if (!profile.isSignedIn) ...[
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Continue as guest'),
              onTap: provider.signInAnonymously,
            ),
            ListTile(
              leading: const Icon(Icons.g_mobiledata),
              title: const Text('Sign in with Google'),
              subtitle: const Text('Firebase sync coming soon'),
              onTap: provider.signInWithGoogle,
            ),
            ListTile(
              leading: const Icon(Icons.apple),
              title: const Text('Sign in with Apple'),
              subtitle: const Text('Firebase sync coming soon'),
              onTap: provider.signInWithApple,
            ),
          ] else
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: provider.signOut,
            ),
        ],
      ),
    );
  }
}
