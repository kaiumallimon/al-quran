import 'ayah_model.dart';

/// Daily verse displayed on the home dashboard.
class DailyVerseModel {
  const DailyVerseModel({
    required this.ayah,
    required this.surahName,
    required this.englishName,
    required this.date,
  });

  final AyahModel ayah;
  final String surahName;
  final String englishName;
  final DateTime date;

  String get reference => '${ayah.surahNumber}:${ayah.numberInSurah}';

  factory DailyVerseModel.fromMap(Map<dynamic, dynamic> map) {
    return DailyVerseModel(
      ayah: AyahModel.fromMap(map['ayah'] as Map<dynamic, dynamic>),
      surahName: map['surahName'] as String,
      englishName: map['englishName'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'ayah': ayah.toMap(),
        'surahName': surahName,
        'englishName': englishName,
        'date': date.toIso8601String(),
      };
}
