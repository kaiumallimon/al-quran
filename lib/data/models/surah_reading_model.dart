import 'ayah_model.dart';
import 'surah_model.dart';

/// A surah with its ayahs ready for the reading screen.
class SurahReadingModel {
  const SurahReadingModel({
    required this.surah,
    required this.ayahs,
  });

  final SurahModel surah;
  final List<AyahModel> ayahs;
}
