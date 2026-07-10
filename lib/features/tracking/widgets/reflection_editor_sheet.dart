import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/reflection_model.dart';
import '../providers/tracking_provider.dart';

/// Editor sheet for a reflection with auto-save.
void showReflectionEditorSheet(
  BuildContext context, {
  required ReflectionModel reflection,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _ReflectionEditorSheet(reflection: reflection),
  );
}

class _ReflectionEditorSheet extends StatefulWidget {
  const _ReflectionEditorSheet({required this.reflection});

  final ReflectionModel reflection;

  @override
  State<_ReflectionEditorSheet> createState() => _ReflectionEditorSheetState();
}

class _ReflectionEditorSheetState extends State<_ReflectionEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.reflection.content);
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
            'Reflection · ${widget.reflection.reference}',
            style: AppTypography.subtitle(context),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Write your reflection…',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) =>
                provider.scheduleReflectionSave(widget.reflection, value),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Reflections are kept separate from notes · Auto-saves',
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
