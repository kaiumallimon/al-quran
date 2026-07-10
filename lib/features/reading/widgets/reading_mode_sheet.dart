import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/reading_mode.dart';
import '../providers/reading_provider.dart';

/// Bottom sheet for selecting a reading mode.
void showReadingModeSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => const _ReadingModeSheet(),
  );
}

class _ReadingModeSheet extends StatelessWidget {
  const _ReadingModeSheet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReadingProvider>();
    final current = provider.preferences.readingMode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Reading Mode', style: AppTypography.title(context)),
            const SizedBox(height: AppSpacing.md),
            ...ReadingMode.values.map((mode) {
              return RadioListTile<ReadingMode>(
                value: mode,
                groupValue: current,
                title: Text(mode.label),
                subtitle: Text(
                  mode.description,
                  style: AppTypography.small(context),
                ),
                onChanged: (value) {
                  if (value != null) {
                    provider.setReadingMode(value);
                    Navigator.pop(context);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
