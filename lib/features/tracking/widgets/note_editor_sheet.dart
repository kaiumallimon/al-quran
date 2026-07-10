import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/note_model.dart';
import '../providers/tracking_provider.dart';

/// Editor sheet for a note with auto-save.
void showNoteEditorSheet(BuildContext context, {required NoteModel note}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _NoteEditorSheet(note: note),
  );
}

class _NoteEditorSheet extends StatefulWidget {
  const _NoteEditorSheet({required this.note});

  final NoteModel note;

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TrackingProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Note · ${widget.note.reference}',
            style: AppTypography.subtitle(context),
          ),
          if (widget.note.ayahPreview != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.note.ayahPreview!,
              style: AppTypography.arabic(fontSize: 18),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Write your private note…',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) =>
                provider.scheduleNoteSave(widget.note, value),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Auto-saves while typing',
            style: AppTypography.small(context).copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
