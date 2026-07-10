import 'package:flutter/material.dart';

import '../../features/reading/pages/reading_screen_page.dart';
import '../../features/reading/pages/surah_list_page.dart';

/// Navigation helpers for reading flows.
class ReadingNavigation {
  ReadingNavigation._();

  static void openSurah(
    BuildContext context, {
    required int surahNumber,
    int? initialAyah,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReadingScreenPage(
          surahNumber: surahNumber,
          initialAyah: initialAyah,
        ),
      ),
    );
  }

  static void openSurahList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SurahListPage(),
      ),
    );
  }
}
