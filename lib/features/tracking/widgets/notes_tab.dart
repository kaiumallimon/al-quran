import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/reading_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/models/note_model.dart';
import '../providers/tracking_provider.dart';
import 'note_editor_sheet.dart';

/// Notes tab with search and pin support.
class NotesTab extends StatelessWidget {
  const NotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SearchBar(
                hintText: 'Search notes…',
                leading: const Icon(Icons.search),
                onChanged: provider.setNoteQuery,
              ),
            ),
            Expanded(
              child: provider.notes.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.note_alt_outlined,
                      title: 'No notes yet',
                      subtitle: 'Add notes to verses while reading',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: provider.notes.length,
                      itemBuilder: (context, index) {
                        final note = provider.notes[index];
                        return _NoteTile(
                          note: note,
                          onTap: () => showNoteEditorSheet(context, note: note),
                          onPin: () => provider.toggleNotePin(note),
                          onDelete: () => provider.deleteNote(note.id),
                          onOpenVerse: () => ReadingNavigation.openSurah(
                            context,
                            surahNumber: note.surahNumber,
                            initialAyah: note.numberInSurah,
                          ),
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

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.onTap,
    required this.onPin,
    required this.onDelete,
    required this.onOpenVerse,
  });

  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onPin;
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
        leading: note.isPinned
            ? Icon(Icons.push_pin, color: colorScheme.primary, size: 20)
            : null,
        title: Text(
          '${note.surahEnglishName ?? 'Surah'} ${note.reference}',
          style: AppTypography.body(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          note.content.isEmpty ? 'Empty note' : note.content,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onTap();
              case 'verse':
                onOpenVerse();
              case 'pin':
                onPin();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'verse', child: Text('Open verse')),
            PopupMenuItem(
              value: 'pin',
              child: Text(note.isPinned ? 'Unpin' : 'Pin'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
