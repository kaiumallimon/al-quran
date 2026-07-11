import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/models/reading_mode.dart';
import '../providers/reading_provider.dart';
import 'reading_mode_sheet.dart';
import 'translation_display_sheet.dart';

/// Compact reading controls below the app bar.
class ReadingControlsBar extends StatelessWidget {
  const ReadingControlsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReadingProvider>();
    final prefs = provider.preferences;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ControlChip(
                icon: Icons.text_increase,
                label: 'A+',
                onTap: () => provider.setArabicFontSize(
                  (prefs.arabicFontSize + 2).clamp(18, 48),
                ),
              ),
              _ControlChip(
                icon: Icons.text_decrease,
                label: 'A−',
                onTap: () => provider.setArabicFontSize(
                  (prefs.arabicFontSize - 2).clamp(18, 48),
                ),
              ),
              _ControlChip(
                icon: prefs.showTranslations
                    ? Icons.translate
                    : Icons.translate_outlined,
                label: 'Translation',
                isActive: prefs.showTranslations,
                onTap: () => showTranslationDisplaySheet(context),
              ),
              _ControlChip(
                icon: Icons.auto_stories_outlined,
                label: prefs.readingMode.label,
                isActive: prefs.readingMode != ReadingMode.normal,
                onTap: () => showReadingModeSheet(context),
              ),
              _ControlChip(
                icon: Icons.download_outlined,
                label: 'Save',
                onTap: () async {
                  await provider.downloadCurrentSurah();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Surah saved for offline')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: ActionChip(
        avatar: Icon(
          icon,
          size: 16,
          color: isActive ? colorScheme.onPrimaryContainer : null,
        ),
        label: Text(label),
        onPressed: onTap,
        backgroundColor: isActive
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        labelStyle: TextStyle(
          fontSize: 12,
          color: isActive ? colorScheme.onPrimaryContainer : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
