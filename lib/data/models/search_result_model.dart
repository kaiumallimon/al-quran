/// A single verse search result.
class SearchResultModel {
  const SearchResultModel({
    required this.surahNumber,
    required this.numberInSurah,
    required this.previewText,
    required this.surahEnglishName,
    required this.matchedIn,
    this.globalAyahNumber,
    this.arabicText,
    this.englishText,
    this.surahArabicName,
    this.isLocal = false,
  });

  final int surahNumber;
  final int numberInSurah;
  final int? globalAyahNumber;
  final String previewText;
  final String? arabicText;
  final String? englishText;
  final String surahEnglishName;
  final String? surahArabicName;
  /// Where the match was found: arabic, english, bangla, surah_name
  final String matchedIn;
  final bool isLocal;

  String get reference => '$surahNumber:$numberInSurah';

  Map<String, dynamic> toMap() => {
        'surahNumber': surahNumber,
        'numberInSurah': numberInSurah,
        if (globalAyahNumber != null) 'globalAyahNumber': globalAyahNumber,
        'previewText': previewText,
        if (arabicText != null) 'arabicText': arabicText,
        if (englishText != null) 'englishText': englishText,
        'surahEnglishName': surahEnglishName,
        if (surahArabicName != null) 'surahArabicName': surahArabicName,
        'matchedIn': matchedIn,
        'isLocal': isLocal,
      };

  factory SearchResultModel.fromMap(Map<dynamic, dynamic> map) {
    return SearchResultModel(
      surahNumber: map['surahNumber'] as int,
      numberInSurah: map['numberInSurah'] as int,
      globalAyahNumber: map['globalAyahNumber'] as int?,
      previewText: map['previewText'] as String,
      arabicText: map['arabicText'] as String?,
      englishText: map['englishText'] as String?,
      surahEnglishName: map['surahEnglishName'] as String,
      surahArabicName: map['surahArabicName'] as String?,
      matchedIn: map['matchedIn'] as String,
      isLocal: map['isLocal'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResultModel &&
          surahNumber == other.surahNumber &&
          numberInSurah == other.numberInSurah &&
          matchedIn == other.matchedIn;

  @override
  int get hashCode => Object.hash(surahNumber, numberInSurah, matchedIn);
}
