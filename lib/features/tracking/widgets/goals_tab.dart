import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/models/tracking_goal_model.dart';
import '../providers/tracking_provider.dart';

/// Reading goals tab with progress bars.
class GoalsTab extends StatelessWidget {
  const GoalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            provider.goals.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.flag_outlined,
                    title: 'No goals set',
                    subtitle: 'Create a daily, weekly, or custom goal',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: provider.goals.length,
                    itemBuilder: (context, index) {
                      final goal = provider.goals[index];
                      return _GoalCard(
                        goal: goal,
                        onDelete: () => provider.deleteGoal(goal.id),
                      );
                    },
                  ),
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: FloatingActionButton.extended(
                onPressed: () => _showCreateGoalDialog(context, provider),
                icon: const Icon(Icons.add),
                label: const Text('New Goal'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateGoalDialog(BuildContext context, TrackingProvider provider) {
    var type = GoalTypes.daily;
    var unit = GoalUnits.ayahs;
    var target = 10;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: GoalTypes.daily, child: Text('Daily')),
                    DropdownMenuItem(
                        value: GoalTypes.weekly, child: Text('Weekly')),
                    DropdownMenuItem(
                        value: GoalTypes.monthly, child: Text('Monthly')),
                    DropdownMenuItem(
                        value: GoalTypes.custom, child: Text('Custom')),
                  ],
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
                DropdownButtonFormField<String>(
                  value: unit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: const [
                    DropdownMenuItem(
                        value: GoalUnits.ayahs, child: Text('Ayahs')),
                    DropdownMenuItem(
                        value: GoalUnits.pages, child: Text('Pages')),
                    DropdownMenuItem(
                        value: GoalUnits.minutes, child: Text('Minutes')),
                    DropdownMenuItem(value: GoalUnits.juz, child: Text('Juz')),
                    DropdownMenuItem(
                        value: GoalUnits.surahs, child: Text('Surahs')),
                  ],
                  onChanged: (v) => setState(() => unit = v ?? unit),
                ),
                TextFormField(
                  initialValue: '$target',
                  decoration: const InputDecoration(labelText: 'Target'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => target = int.tryParse(v) ?? target,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  await provider.createGoal(
                    type: type,
                    unit: unit,
                    target: target,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.onDelete});

  final TrackingGoalModel goal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = goal.progressPercent;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.displayTitle,
                      style: AppTypography.subtitle(context),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    '${goal.completed}',
                    style: AppTypography.headline(context).copyWith(
                      color: colorScheme.primary,
                      fontSize: 24,
                    ),
                  ),
                  Text(' / ${goal.target} ${goal.unit}'),
                  const Spacer(),
                  Text('${(percent * 100).toInt()}%'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                ),
              ),
              if (goal.isComplete)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Completed · MashaAllah',
                    style: AppTypography.caption(context).copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
