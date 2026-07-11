/// Constants for the alquran.cloud API.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.alquran.cloud/v1';

  static const String editionArabic = 'quran-uthmani';
  static const String editionEnglish = 'en.sahih';
  /// Latin-script pronunciation from alquran.cloud transliteration type.
  static const String editionTransliteration = 'en.transliteration';
  static const String editionBanglaTranslation = 'bn.bengali';

  /// Editions fetched together for a full reading experience.
  static const List<String> surahReadingEditions = [
    editionArabic,
    editionEnglish,
    editionTransliteration,
    editionBanglaTranslation,
  ];

  static const Duration requestTimeout = Duration(seconds: 30);
}
