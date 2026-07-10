import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/ayah_model.dart';
import '../../../data/models/reading_preferences_model.dart';
import 'verse_actions_sheet.dart';

/// Single ayah card with Arabic, translations, and actions.
class AyahCard extends StatelessWidget {
  const AyahCard({
    super.key,
    required this.ayah,
    required this.preferences,
    required this.surahEnglishName,
    required this.isHighlighted,
    this.itemKey,
    this.onTap,
    this.onLongPress,
    this.isFocusMode = false,
  });

  final AyahModel ayah;
  final ReadingPreferencesModel preferences;
  final String surahEnglishName;
  final bool isHighlighted;
  final Key? itemKey;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isFocusMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: itemKey,
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: isFocusMode ? AppSpacing.sm : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isHighlighted
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress ??
              () => showVerseActionsSheet(
                    context,
                    ayah: ayah,
                    surahEnglishName: surahEnglishName,
                  ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isFocusMode)
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '${ayah.numberInSurah}',
                          style: AppTypography.small(context).copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (ayah.sajda) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.mosque_outlined,
                          size: 16,
                          color: colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        Text(
                          ' Sajda',
                          style: AppTypography.small(context).copyWith(
                            color: colorScheme.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, size: 20),
                        onPressed: () => showVerseActionsSheet(
                          context,
                          ayah: ayah,
                          surahEnglishName: surahEnglishName,
                        ),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Verse actions',
                      ),
                    ],
                  ),
                if (preferences.showArabic) ...[
                  if (!isFocusMode) const SizedBox(height: AppSpacing.sm),
                  Text(
                    ayah.text,
                    style: AppTypography.arabic(
                      fontSize: preferences.arabicFontSize,
                      color: colorScheme.onSurface,
                    ).copyWith(height: preferences.lineHeight),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
                if (preferences.showTranslationText &&
                    ayah.englishText != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    ayah.englishText!,
                    style: AppTypography.body(context).copyWith(
                      fontSize: preferences.translationFontSize,
                      height: preferences.lineHeight,
                      color: colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                if (preferences.showTranslationText &&
                    ayah.banglaTransliteration != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ayah.banglaTransliteration!,
                    style: AppTypography.bangla(
                      fontSize: preferences.translationFontSize - 2,
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
