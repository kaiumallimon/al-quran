/// A bookmarked verse.
class BookmarkModel {
  const BookmarkModel({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.numberInSurah,
    required this.createdAt,
    required this.updatedAt,
    this.surahEnglishName,
    this.surahArabicName,
    this.ayahPreview,
    this.note,
    this.folder = 'General',
  });

  final String id;
  final int surahNumber;
  final int ayahNumber;
  final int numberInSurah;
  final String? surahEnglishName;
  final String? surahArabicName;
  final String? ayahPreview;
  final String? note;
  final String folder;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get reference => '$surahNumber:$numberInSurah';

  BookmarkModel copyWith({
    String? note,
    String? folder,
    DateTime? updatedAt,
  }) {
    return BookmarkModel(
      id: id,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      numberInSurah: numberInSurah,
      surahEnglishName: surahEnglishName,
      surahArabicName: surahArabicName,
      ayahPreview: ayahPreview,
      note: note ?? this.note,
      folder: folder ?? this.folder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory BookmarkModel.fromMap(Map<dynamic, dynamic> map) {
    return BookmarkModel(
      id: map['id'] as String,
      surahNumber: map['surahNumber'] as int,
      ayahNumber: map['ayahNumber'] as int,
      numberInSurah: map['numberInSurah'] as int,
      surahEnglishName: map['surahEnglishName'] as String?,
      surahArabicName: map['surahArabicName'] as String?,
      ayahPreview: map['ayahPreview'] as String?,
      note: map['note'] as String?,
      folder: map['folder'] as String? ?? 'General',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'numberInSurah': numberInSurah,
        if (surahEnglishName != null) 'surahEnglishName': surahEnglishName,
        if (surahArabicName != null) 'surahArabicName': surahArabicName,
        if (ayahPreview != null) 'ayahPreview': ayahPreview,
        if (note != null) 'note': note,
        'folder': folder,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
