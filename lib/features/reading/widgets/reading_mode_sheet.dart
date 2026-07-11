import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../data/models/reading_mode.dart';
import '../providers/reading_provider.dart';

/// Bottom sheet for selecting a reading mode.
void showReadingModeSheet(BuildContext context) {
  AppBottomSheet.show<void>(
    context,
    initialChildSize: 0.55,
    minChildSize: 0.35,
    maxChildSize: 0.85,
    child: const _ReadingModeSheet(),
  );
}

class _ReadingModeSheet extends StatelessWidget {
  const _ReadingModeSheet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReadingProvider>();
    final current = provider.preferences.readingMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Reading Mode', style: AppTypography.title(context)),
        const SizedBox(height: AppSpacing.md),
        ...ReadingMode.values.map((mode) {
          return RadioListTile<ReadingMode>(
            contentPadding: EdgeInsets.zero,
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
    );
  }
}
