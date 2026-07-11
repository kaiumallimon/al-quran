import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../providers/reading_provider.dart';

/// Bottom sheet for choosing which translation layers are visible.
void showTranslationDisplaySheet(BuildContext context) {
  AppBottomSheet.show<void>(
    context,
    initialChildSize: 0.42,
    minChildSize: 0.28,
    maxChildSize: 0.7,
    child: const _TranslationDisplaySheet(),
  );
}

class _TranslationDisplaySheet extends StatelessWidget {
  const _TranslationDisplaySheet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReadingProvider>();
    final prefs = provider.preferences;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Translations', style: AppTypography.title(context)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Choose what to show below each ayah',
          style: AppTypography.small(context).copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show translations'),
          subtitle: const Text('Master toggle for all layers'),
          value: prefs.showTranslations,
          onChanged: provider.setShowTranslations,
        ),
        const Divider(height: AppSpacing.lg),
        _LayerSwitch(
          title: 'English',
          subtitle: 'Saheeh International',
          value: prefs.showEnglishTranslation,
          enabled: prefs.showTranslations,
          onChanged: provider.setShowEnglishTranslation,
        ),
        _LayerSwitch(
          title: 'Transliteration',
          subtitle: 'Pronunciation / spelling guide',
          value: prefs.showTransliteration,
          enabled: prefs.showTranslations,
          onChanged: provider.setShowTransliteration,
        ),
        _LayerSwitch(
          title: 'Bangla',
          subtitle: 'Muhiuddin Khan translation',
          value: prefs.showBanglaTranslation,
          enabled: prefs.showTranslations,
          onChanged: provider.setShowBanglaTranslation,
        ),
      ],
    );
  }
}

class _LayerSwitch extends StatelessWidget {
  const _LayerSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle, style: AppTypography.small(context)),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}
