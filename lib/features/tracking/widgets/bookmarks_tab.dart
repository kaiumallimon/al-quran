import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/reading_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/models/bookmark_model.dart';
import '../providers/tracking_provider.dart';

/// Bookmarks tab with folder filter and search.
class BookmarksTab extends StatelessWidget {
  const BookmarksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SearchBar(
                hintText: 'Search bookmarks…',
                leading: const Icon(Icons.search),
                onChanged: provider.setBookmarkQuery,
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  'All',
                  ...provider.bookmarkFolders,
                ].map((folder) {
                  final selected = provider.bookmarkFolder == folder;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(folder),
                      selected: selected,
                      onSelected: (_) => provider.setBookmarkFolder(folder),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: provider.bookmarks.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.bookmark_border,
                      title: 'No bookmarks yet',
                      subtitle: 'Bookmark verses while reading',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: provider.bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = provider.bookmarks[index];
                        return _BookmarkTile(
                          bookmark: bookmark,
                          onTap: () => ReadingNavigation.openSurah(
                            context,
                            surahNumber: bookmark.surahNumber,
                            initialAyah: bookmark.numberInSurah,
                          ),
                          onDelete: () =>
                              provider.deleteBookmark(bookmark.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  final BookmarkModel bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

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
          '${bookmark.surahEnglishName} ${bookmark.reference}',
          style: AppTypography.body(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bookmark.ayahPreview != null)
              Text(
                bookmark.ayahPreview!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
              ),
            Text(
              '${bookmark.folder} · ${_formatDate(bookmark.updatedAt)}',
              style: AppTypography.small(context).copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
