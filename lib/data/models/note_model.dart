/// A private note attached to a verse.
class NoteModel {
  const NoteModel({
    required this.id,
    required this.surahNumber,
    required this.numberInSurah,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.surahEnglishName,
    this.ayahPreview,
    this.isPinned = false,
    this.isFavorite = false,
  });

  final String id;
  final int surahNumber;
  final int numberInSurah;
  final String content;
  final String? surahEnglishName;
  final String? ayahPreview;
  final bool isPinned;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get reference => '$surahNumber:$numberInSurah';

  NoteModel copyWith({
    String? content,
    bool? isPinned,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id,
      surahNumber: surahNumber,
      numberInSurah: numberInSurah,
      content: content ?? this.content,
      surahEnglishName: surahEnglishName,
      ayahPreview: ayahPreview,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NoteModel.fromMap(Map<dynamic, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      surahNumber: map['surahNumber'] as int,
      numberInSurah: map['numberInSurah'] as int,
      content: map['content'] as String,
      surahEnglishName: map['surahEnglishName'] as String?,
      ayahPreview: map['ayahPreview'] as String?,
      isPinned: map['isPinned'] as bool? ?? false,
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
        'isPinned': isPinned,
        'isFavorite': isFavorite,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
