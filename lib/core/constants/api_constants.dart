/// Constants for the alquran.cloud API.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.alquran.cloud/v1';

  static const String editionArabic = 'quran-uthmani';
  static const String editionEnglish = 'en.sahih';
  static const String editionBanglaTransliteration = 'bn.bengali';
  static const String editionBanglaTranslation = 'bn.bengali';

  static const Duration requestTimeout = Duration(seconds: 30);
}
