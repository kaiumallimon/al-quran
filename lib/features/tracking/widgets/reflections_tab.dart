import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/reading_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/models/reflection_model.dart';
import '../providers/tracking_provider.dart';
import 'reflection_editor_sheet.dart';

/// Reflections tab with calendar-style date grouping.
class ReflectionsTab extends StatelessWidget {
  const ReflectionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(
      builder: (context, provider, _) {
        if (provider.reflections.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.edit_note_outlined,
            title: 'No reflections yet',
            subtitle: 'Record personal reflections on verses',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: provider.reflections.length,
          itemBuilder: (context, index) {
            final reflection = provider.reflections[index];
            return _ReflectionTile(
              reflection: reflection,
              onTap: () =>
                  showReflectionEditorSheet(context, reflection: reflection),
              onDelete: () => provider.deleteReflection(reflection.id),
              onOpenVerse: () => ReadingNavigation.openSurah(
                context,
                surahNumber: reflection.surahNumber,
                initialAyah: reflection.numberInSurah,
              ),
            );
          },
        );
      },
    );
  }
}

class _ReflectionTile extends StatelessWidget {
  const _ReflectionTile({
    required this.reflection,
    required this.onTap,
    required this.onDelete,
    required this.onOpenVerse,
  });

  final ReflectionModel reflection;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onOpenVerse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        title: Text(
          '${reflection.surahEnglishName ?? 'Surah'} ${reflection.reference}',
          style: AppTypography.body(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reflection.content.isEmpty
                  ? 'Empty reflection'
                  : reflection.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _formatDate(reflection.updatedAt),
              style: AppTypography.small(context).copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onTap();
              case 'verse':
                onOpenVerse();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'verse', child: Text('Open verse')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
