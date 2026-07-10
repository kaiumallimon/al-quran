import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/reading_progress_model.dart';

/// Card showing where the user left off reading.
class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({
    super.key,
    required this.progress,
    this.onResume,
  });

  final ReadingProgressModel progress;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeAgo = _formatTimeAgo(progress.lastReadAt);

    return AppCard(
      onTap: onResume,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, color: colorScheme.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Continue Reading',
                style: AppTypography.caption(context).copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            progress.englishName ?? 'Surah ${progress.surahNumber}',
            style: AppTypography.title(context),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ayah ${progress.ayahNumber} · Page ${progress.page}',
            style: AppTypography.caption(context).copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                timeAgo,
                style: AppTypography.small(context).copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              if (progress.progressPercent > 0)
                Text(
                  '${(progress.progressPercent * 100).toInt()}%',
                  style: AppTypography.small(context).copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (progress.progressPercent > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.progressPercent,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
                minHeight: 4,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onResume,
              child: const Text('Resume'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.MMMd().format(dateTime);
  }
}

/// Empty continue reading prompt.
class ContinueReadingEmpty extends StatelessWidget {
  const ContinueReadingEmpty({super.key, this.onStart});

  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start your reading journey',
            style: AppTypography.subtitle(context),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Open any surah to begin tracking your progress',
            style: AppTypography.caption(context).copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (onStart != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onStart, child: const Text('Browse Surahs')),
          ],
        ],
      ),
    );
  }
}
