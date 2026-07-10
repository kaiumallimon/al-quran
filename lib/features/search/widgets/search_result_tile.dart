import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/search_result_model.dart';
import 'highlighted_text.dart';

/// Single search result row.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.result,
    required this.query,
    required this.onTap,
  });

  final SearchResultModel result;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        result.reference,
                        style: AppTypography.small(context).copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        result.surahEnglishName,
                        style: AppTypography.caption(context).copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (result.isLocal)
                      Icon(
                        Icons.offline_pin,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (result.arabicText != null &&
                    result.matchedIn != 'english' &&
                    result.matchedIn != 'bangla')
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: HighlightedText(
                      text: result.arabicText!,
                      highlight: query,
                      style: AppTypography.arabic(
                        fontSize: 20,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 3,
                    ),
                  ),
                HighlightedText(
                  text: result.previewText,
                  highlight: query,
                  style: AppTypography.body(context).copyWith(height: 1.5),
                  maxLines: 3,
                ),
                if (result.englishText != null &&
                    result.matchedIn != 'surah_name' &&
                    result.previewText != result.englishText)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: HighlightedText(
                      text: result.englishText!,
                      highlight: query,
                      style: AppTypography.caption(context).copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// List of search results.
class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    super.key,
    required this.results,
    required this.query,
    required this.onResultTap,
    this.isRemoteLoading = false,
  });

  final List<SearchResultModel> results;
  final String query;
  final void Function(SearchResultModel result) onResultTap;
  final bool isRemoteLoading;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: isRemoteLoading
              ? '${results.length} result${results.length == 1 ? '' : 's'} · updating…'
              : '${results.length} result${results.length == 1 ? '' : 's'}',
        ),
        ...results.map(
          (result) => SearchResultTile(
            result: result,
            query: query,
            onTap: () => onResultTap(result),
          ),
        ),
      ],
    );
  }
}
