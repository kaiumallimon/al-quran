/// Tracks the user's last reading position.
class ReadingProgressModel {
  const ReadingProgressModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.page,
    required this.lastReadAt,
    this.surahName,
    this.englishName,
    this.progressPercent = 0,
  });

  final int surahNumber;
  final int ayahNumber;
  final int page;
  final DateTime lastReadAt;
  final String? surahName;
  final String? englishName;
  final double progressPercent;

  factory ReadingProgressModel.fromMap(Map<dynamic, dynamic> map) {
    return ReadingProgressModel(
      surahNumber: map['surahNumber'] as int,
      ayahNumber: map['ayahNumber'] as int,
      page: map['page'] as int,
      lastReadAt: DateTime.parse(map['lastReadAt'] as String),
      surahName: map['surahName'] as String?,
      englishName: map['englishName'] as String?,
      progressPercent: (map['progressPercent'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'page': page,
        'lastReadAt': lastReadAt.toIso8601String(),
        if (surahName != null) 'surahName': surahName,
        if (englishName != null) 'englishName': englishName,
        'progressPercent': progressPercent,
      };
}
