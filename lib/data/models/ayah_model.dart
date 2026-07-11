/// Represents a single Ayah (verse) in the Quran.
class AyahModel {
  const AyahModel({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.surahNumber,
    this.juz,
    this.manzil,
    this.page,
    this.ruku,
    this.hizbQuarter,
    this.sajda = false,
    this.englishText,
    this.transliteration,
    this.banglaTranslation,
  });

  final int number;
  final String text;
  final int numberInSurah;
  final int surahNumber;
  final int? juz;
  final int? manzil;
  final int? page;
  final int? ruku;
  final int? hizbQuarter;
  final bool sajda;
  final String? englishText;
  /// Pronunciation from alquran.cloud `en.transliteration`.
  final String? transliteration;
  final String? banglaTranslation;

  factory AyahModel.fromJson(
    Map<String, dynamic> json, {
    int? surahNumber,
  }) {
    final surah = json['surah'] as Map<String, dynamic>?;
    return AyahModel(
      number: json['number'] as int,
      text: json['text'] as String,
      numberInSurah: json['numberInSurah'] as int,
      surahNumber: surahNumber ?? (surah?['number'] as int?) ?? 0,
      juz: json['juz'] as int?,
      manzil: json['manzil'] as int?,
      page: json['page'] as int?,
      ruku: json['ruku'] as int?,
      hizbQuarter: json['hizbQuarter'] as int?,
      sajda: json['sajda'] == true ||
          (json['sajda'] is Map && json['sajda'] != null),
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'text': text,
        'numberInSurah': numberInSurah,
        'surahNumber': surahNumber,
        if (juz != null) 'juz': juz,
        if (manzil != null) 'manzil': manzil,
        if (page != null) 'page': page,
        if (ruku != null) 'ruku': ruku,
        if (hizbQuarter != null) 'hizbQuarter': hizbQuarter,
        'sajda': sajda,
        if (englishText != null) 'englishText': englishText,
        if (transliteration != null) 'transliteration': transliteration,
        if (banglaTranslation != null)
          'banglaTranslation': banglaTranslation,
      };

  factory AyahModel.fromMap(Map<dynamic, dynamic> map) {
    return AyahModel(
      number: map['number'] as int,
      text: map['text'] as String,
      numberInSurah: map['numberInSurah'] as int,
      surahNumber: map['surahNumber'] as int,
      juz: map['juz'] as int?,
      manzil: map['manzil'] as int?,
      page: map['page'] as int?,
      ruku: map['ruku'] as int?,
      hizbQuarter: map['hizbQuarter'] as int?,
      sajda: map['sajda'] as bool? ?? false,
      englishText: map['englishText'] as String?,
      transliteration: map['transliteration'] as String? ??
          map['banglaTransliteration'] as String?,
      banglaTranslation: map['banglaTranslation'] as String?,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  AyahModel copyWith({
    String? englishText,
    String? transliteration,
    String? banglaTranslation,
  }) {
    return AyahModel(
      number: number,
      text: text,
      numberInSurah: numberInSurah,
      surahNumber: surahNumber,
      juz: juz,
      manzil: manzil,
      page: page,
      ruku: ruku,
      hizbQuarter: hizbQuarter,
      sajda: sajda,
      englishText: englishText ?? this.englishText,
      transliteration: transliteration ?? this.transliteration,
      banglaTranslation: banglaTranslation ?? this.banglaTranslation,
    );
  }

  String get reference => '$surahNumber:$numberInSurah';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AyahModel && number == other.number;

  @override
  int get hashCode => number.hashCode;
}
