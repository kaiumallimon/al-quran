import '../../../core/constants/app_constants.dart';
import 'reading_mode.dart';

/// User reading display preferences persisted locally.
class ReadingPreferencesModel {
  const ReadingPreferencesModel({
    this.arabicFontSize = AppConstants.defaultArabicFontSize,
    this.translationFontSize = AppConstants.defaultTranslationFontSize,
    this.showTranslations = true,
    this.readingMode = ReadingMode.normal,
    this.preferredReciter = 'ar.alafasy',
    this.lineHeight = 1.8,
  });

  final double arabicFontSize;
  final double translationFontSize;
  final bool showTranslations;
  final ReadingMode readingMode;
  final String preferredReciter;
  final double lineHeight;

  bool get showArabic =>
      readingMode != ReadingMode.translationOnly;

  bool get showTranslationText {
    if (!showTranslations) return false;
    return readingMode != ReadingMode.arabicOnly;
  }

  ReadingPreferencesModel copyWith({
    double? arabicFontSize,
    double? translationFontSize,
    bool? showTranslations,
    ReadingMode? readingMode,
    String? preferredReciter,
    double? lineHeight,
  }) {
    return ReadingPreferencesModel(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      showTranslations: showTranslations ?? this.showTranslations,
      readingMode: readingMode ?? this.readingMode,
      preferredReciter: preferredReciter ?? this.preferredReciter,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }

  factory ReadingPreferencesModel.fromMap(Map<dynamic, dynamic> map) {
    return ReadingPreferencesModel(
      arabicFontSize:
          (map['arabicFontSize'] as num?)?.toDouble() ??
              AppConstants.defaultArabicFontSize,
      translationFontSize:
          (map['translationFontSize'] as num?)?.toDouble() ??
              AppConstants.defaultTranslationFontSize,
      showTranslations: map['showTranslations'] as bool? ?? true,
      readingMode: ReadingMode.fromString(
        map['readingMode'] as String? ?? 'normal',
      ),
      preferredReciter: map['preferredReciter'] as String? ?? 'ar.alafasy',
      lineHeight: (map['lineHeight'] as num?)?.toDouble() ?? 1.8,
    );
  }

  Map<String, dynamic> toMap() => {
        'arabicFontSize': arabicFontSize,
        'translationFontSize': translationFontSize,
        'showTranslations': showTranslations,
        'readingMode': readingMode.name,
        'preferredReciter': preferredReciter,
        'lineHeight': lineHeight,
      };
}
