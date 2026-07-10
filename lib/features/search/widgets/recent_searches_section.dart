import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/section_header.dart';

/// Horizontal chips for recent search queries.
class RecentSearchesSection extends StatelessWidget {
  const RecentSearchesSection({
    super.key,
    required this.searches,
    required this.onTap,
    required this.onClear,
  });

  final List<String> searches;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Recent Searches',
          action: onClear,
          actionLabel: 'Clear',
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: searches.map((search) {
            return ActionChip(
              avatar: const Icon(Icons.history, size: 16),
              label: Text(search),
              onPressed: () => onTap(search),
            );
          }).toList(),
        ),
      ],
    );
  }
}
