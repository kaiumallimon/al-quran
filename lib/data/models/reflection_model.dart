/// A personal reflection journal entry for a verse.
class ReflectionModel {
  const ReflectionModel({
    required this.id,
    required this.surahNumber,
    required this.numberInSurah,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.surahEnglishName,
    this.ayahPreview,
    this.isFavorite = false,
  });

  final String id;
  final int surahNumber;
  final int numberInSurah;
  final String content;
  final String? surahEnglishName;
  final String? ayahPreview;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get reference => '$surahNumber:$numberInSurah';

  ReflectionModel copyWith({
    String? content,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return ReflectionModel(
      id: id,
      surahNumber: surahNumber,
      numberInSurah: numberInSurah,
      content: content ?? this.content,
      surahEnglishName: surahEnglishName,
      ayahPreview: ayahPreview,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ReflectionModel.fromMap(Map<dynamic, dynamic> map) {
    return ReflectionModel(
      id: map['id'] as String,
      surahNumber: map['surahNumber'] as int,
      numberInSurah: map['numberInSurah'] as int,
      content: map['content'] as String,
      surahEnglishName: map['surahEnglishName'] as String?,
      ayahPreview: map['ayahPreview'] as String?,
      isFavorite: map['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'surahNumber': surahNumber,
        'numberInSurah': numberInSurah,
        'content': content,
        if (surahEnglishName != null) 'surahEnglishName': surahEnglishName,
        if (ayahPreview != null) 'ayahPreview': ayahPreview,
        'isFavorite': isFavorite,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
