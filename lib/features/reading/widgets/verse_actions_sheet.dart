import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/ayah_model.dart';
import '../../../data/models/audio_repeat_mode.dart';
import '../../audio/providers/audio_provider.dart';
import '../../tracking/providers/tracking_provider.dart';
import '../../tracking/widgets/note_editor_sheet.dart';
import '../../tracking/widgets/reflection_editor_sheet.dart';

/// Bottom sheet with verse actions.
void showVerseActionsSheet(
  BuildContext context, {
  required AyahModel ayah,
  required String surahEnglishName,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => _VerseActionsSheet(
      ayah: ayah,
      surahEnglishName: surahEnglishName,
    ),
  );
}

class _VerseActionsSheet extends StatelessWidget {
  const _VerseActionsSheet({
    required this.ayah,
    required this.surahEnglishName,
  });

  final AyahModel ayah;
  final String surahEnglishName;

  @override
  Widget build(BuildContext context) {
    final reference = '$surahEnglishName ${ayah.surahNumber}:${ayah.numberInSurah}';

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(reference, style: AppTypography.subtitle(context)),
          ),
          _ActionTile(
            icon: Icons.bookmark_border,
            label: 'Bookmark',
            onTap: () => _toggleBookmark(context),
          ),
          _ActionTile(
            icon: Icons.favorite_border,
            label: 'Favorite',
            onTap: () => _toggleFavorite(context),
          ),
          _ActionTile(
            icon: Icons.copy,
            label: 'Copy',
            onTap: () {
              Clipboard.setData(ClipboardData(text: _formatVerseText()));
              _closeWithMessage(context, 'Verse copied');
            },
          ),
          _ActionTile(
            icon: Icons.note_alt_outlined,
            label: 'Note',
            onTap: () => _createNote(context),
          ),
          _ActionTile(
            icon: Icons.edit_note_outlined,
            label: 'Reflection',
            onTap: () => _createReflection(context),
          ),
          _ActionTile(
            icon: Icons.play_circle_outline,
            label: 'Play audio',
            onTap: () => _playAudio(context),
          ),
          _ActionTile(
            icon: Icons.repeat,
            label: 'Repeat verse',
            onTap: () => _repeatVerse(context),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Future<void> _playAudio(BuildContext context) async {
    final audio = context.read<AudioProvider>();
    Navigator.pop(context);
    await audio.playAyah(
      surahNumber: ayah.surahNumber,
      numberInSurah: ayah.numberInSurah,
      globalAyahNumber: ayah.number,
      surahEnglishName: surahEnglishName,
    );
  }

  Future<void> _repeatVerse(BuildContext context) async {
    final audio = context.read<AudioProvider>();
    Navigator.pop(context);
    await audio.setRepeatMode(AudioRepeatMode.ayah);
    await audio.playAyah(
      surahNumber: ayah.surahNumber,
      numberInSurah: ayah.numberInSurah,
      globalAyahNumber: ayah.number,
      surahEnglishName: surahEnglishName,
    );
  }

  Future<void> _toggleBookmark(BuildContext context) async {
    final provider = context.read<TrackingProvider>();
    final added = await provider.toggleBookmark(
      surahNumber: ayah.surahNumber,
      numberInSurah: ayah.numberInSurah,
      ayahNumber: ayah.number,
      surahEnglishName: surahEnglishName,
      ayahPreview: ayah.text,
    );
    _closeWithMessage(
      context,
      added ? 'Bookmark saved' : 'Bookmark removed',
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final provider = context.read<TrackingProvider>();
    final added = await provider.toggleFavorite(
      surahNumber: ayah.surahNumber,
      numberInSurah: ayah.numberInSurah,
      surahEnglishName: surahEnglishName,
      ayahPreview: ayah.text,
    );
    _closeWithMessage(
      context,
      added ? 'Added to favorites' : 'Removed from favorites',
    );
  }

  Future<void> _createNote(BuildContext context) async {
    final provider = context.read<TrackingProvider>();
    final note = await provider.startNote(
      surahNumber: ayah.surahNumber,
      numberInSurah: ayah.numberInSurah,
      surahEnglishName: surahEnglishName,
      ayahPreview: ayah.text,
    );
    Navigator.pop(context);
    if (context.mounted) showNoteEditorSheet(context, note: note);
  }

  Future<void> _createReflection(BuildContext context) async {
    final provider = context.read<TrackingProvider>();
    final reflection = await provider.startReflection(
      surahNumber: ayah.surahNumber,
      numberInSurah: ayah.numberInSurah,
      surahEnglishName: surahEnglishName,
      ayahPreview: ayah.text,
    );
    Navigator.pop(context);
    if (context.mounted) {
      showReflectionEditorSheet(context, reflection: reflection);
    }
  }

  String _formatVerseText() {
    final buffer = StringBuffer()
      ..writeln(ayah.text)
      ..writeln();
    if (ayah.englishText != null) {
      buffer.writeln(ayah.englishText);
      buffer.writeln();
    }
    if (ayah.transliteration != null) {
      buffer.writeln(ayah.transliteration);
      buffer.writeln();
    }
    if (ayah.banglaTranslation != null) {
      buffer.writeln(ayah.banglaTranslation);
      buffer.writeln();
    }
    buffer.write('— $surahEnglishName ${ayah.surahNumber}:${ayah.numberInSurah}');
    return buffer.toString();
  }

  void _closeWithMessage(BuildContext context, String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
