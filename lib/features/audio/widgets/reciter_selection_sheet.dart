import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../reading/providers/reading_provider.dart';
import '../providers/audio_provider.dart';

/// Bottom sheet for selecting a reciter.
void showReciterSelectionSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => const ReciterSelectionSheet(),
  );
}

class ReciterSelectionSheet extends StatelessWidget {
  const ReciterSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Select reciter'),
              ),
              ...audio.reciters.map(
                (reciter) => ListTile(
                  title: Text(reciter.name),
                  subtitle: Text(reciter.id),
                  trailing: audio.preferences.preferredReciter == reciter.id
                      ? const Icon(Icons.check_circle)
                      : null,
                  onTap: () async {
                    await audio.changeReciter(reciter.id);
                    final reading = (context.mounted) ? context.read<ReadingProvider>() : null;
                    if (reading != null) {
                      await reading.updatePreferences(
                        reading.preferences.copyWith(preferredReciter: reciter.id),
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
