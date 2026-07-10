/// A favorited verse.
class FavoriteModel {
  const FavoriteModel({
    required this.id,
    required this.surahNumber,
    required this.numberInSurah,
    required this.createdAt,
    this.surahEnglishName,
    this.ayahPreview,
  });

  final String id;
  final int surahNumber;
  final int numberInSurah;
  final String? surahEnglishName;
  final String? ayahPreview;
  final DateTime createdAt;

  String get reference => '$surahNumber:$numberInSurah';

  factory FavoriteModel.fromMap(Map<dynamic, dynamic> map) {
    return FavoriteModel(
      id: map['id'] as String,
      surahNumber: map['surahNumber'] as int,
      numberInSurah: map['numberInSurah'] as int,
      surahEnglishName: map['surahEnglishName'] as String?,
      ayahPreview: map['ayahPreview'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'surahNumber': surahNumber,
        'numberInSurah': numberInSurah,
        if (surahEnglishName != null) 'surahEnglishName': surahEnglishName,
        if (ayahPreview != null) 'ayahPreview': ayahPreview,
        'createdAt': createdAt.toIso8601String(),
      };
}
