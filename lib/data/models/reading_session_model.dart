/// Records a single reading session.
class ReadingSessionModel {
  const ReadingSessionModel({
    required this.id,
    required this.startedAt,
    required this.durationMinutes,
    this.pagesRead = 0,
    this.ayahsRead = 0,
    this.surahNumber,
    this.wasOffline = false,
  });

  final String id;
  final DateTime startedAt;
  final int durationMinutes;
  final int pagesRead;
  final int ayahsRead;
  final int? surahNumber;
  final bool wasOffline;

  factory ReadingSessionModel.fromMap(Map<dynamic, dynamic> map) {
    return ReadingSessionModel(
      id: map['id'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      durationMinutes: map['durationMinutes'] as int,
      pagesRead: map['pagesRead'] as int? ?? 0,
      ayahsRead: map['ayahsRead'] as int? ?? 0,
      surahNumber: map['surahNumber'] as int?,
      wasOffline: map['wasOffline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'pagesRead': pagesRead,
        'ayahsRead': ayahsRead,
        if (surahNumber != null) 'surahNumber': surahNumber,
        'wasOffline': wasOffline,
      };
}
