import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

/// Quick action buttons for common tasks.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    this.onBrowseSurahs,
    this.onSearch,
    this.onBookmarks,
    this.onSettings,
  });

  final VoidCallback? onBrowseSurahs;
  final VoidCallback? onSearch;
  final VoidCallback? onBookmarks;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        Row(
          children: [
            _ActionButton(
              icon: Icons.list_alt,
              label: 'Surahs',
              onTap: onBrowseSurahs,
            ),
            _ActionButton(
              icon: Icons.search,
              label: 'Search',
              onTap: onSearch,
            ),
            _ActionButton(
              icon: Icons.bookmark_outline,
              label: 'Bookmarks',
              onTap: onBookmarks,
            ),
            _ActionButton(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: onSettings,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: AppCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.sm,
            ),
            child: Column(
              children: [
                Icon(icon, color: colorScheme.primary, size: 24),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppTypography.small(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
