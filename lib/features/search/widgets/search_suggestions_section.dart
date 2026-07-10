import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/section_header.dart';

/// Suggested search terms based on query prefix.
class SearchSuggestionsSection extends StatelessWidget {
  const SearchSuggestionsSection({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Suggestions'),
        ...suggestions.map((suggestion) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.search, size: 20),
            title: Text(suggestion),
            onTap: () => onTap(suggestion),
            dense: true,
            visualDensity: VisualDensity.compact,
          );
        }),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
