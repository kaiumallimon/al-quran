import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/models/reading_session_model.dart';
import '../providers/tracking_provider.dart';

/// Reading history grouped by date with milestones summary.
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(
      builder: (context, provider, _) {
        if (provider.sessions.isEmpty && provider.milestones.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.history,
            title: 'No reading history',
            subtitle: 'Your reading sessions will appear here',
          );
        }

        return FutureBuilder<Map<DateTime, List<ReadingSessionModel>>>(
          future: provider.getSessionsByDate(),
          builder: (context, snapshot) {
            final grouped = snapshot.data ?? {};
            final dates = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (provider.milestones.isNotEmpty) ...[
                  Text('Milestones', style: AppTypography.subtitle(context)),
                  const SizedBox(height: AppSpacing.sm),
                  ...provider.milestones.take(5).map(
                        (m) => _MilestoneTile(milestone: m),
                      ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text('Reading History', style: AppTypography.subtitle(context)),
                const SizedBox(height: AppSpacing.sm),
                if (dates.isEmpty)
                  Text(
                    'No sessions recorded yet',
                    style: AppTypography.caption(context),
                  )
                else
                  ...dates.map((date) {
                    final sessions = grouped[date]!;
                    return _HistoryDayGroup(date: date, sessions: sessions);
                  }),
              ],
            );
          },
        );
      },
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({required this.milestone});

  final MilestoneModel milestone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(Icons.emoji_events_outlined, color: colorScheme.primary),
        title: Text(milestone.title),
        subtitle: Text(milestone.description),
        dense: true,
      ),
    );
  }
}

class _HistoryDayGroup extends StatelessWidget {
  const _HistoryDayGroup({required this.date, required this.sessions});

  final DateTime date;
  final List<ReadingSessionModel> sessions;

  @override
  Widget build(BuildContext context) {
    final totalAyahs = sessions.fold(0, (sum, s) => sum + s.ayahsRead);
    final totalMinutes =
        sessions.fold(0, (sum, s) => sum + s.durationMinutes);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMEd().format(date),
                style: AppTypography.body(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${sessions.length} session${sessions.length == 1 ? '' : 's'} · '
                '$totalAyahs ayahs · $totalMinutes min',
                style: AppTypography.caption(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
