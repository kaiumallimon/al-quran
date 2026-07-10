/// Summary of reading activity for a time period.
class ReadingSummaryModel {
  const ReadingSummaryModel({
    this.readingMinutes = 0,
    this.pagesRead = 0,
    this.ayahsRead = 0,
    this.sessions = 0,
    this.activeDays = 0,
    this.averageSessionMinutes = 0,
    this.mostReadSurahNumber,
    this.mostReadSurahName,
    this.bestDayAyahs = 0,
    this.bestDayDate,
  });

  final int readingMinutes;
  final int pagesRead;
  final int ayahsRead;
  final int sessions;
  final int activeDays;
  final int averageSessionMinutes;
  final int? mostReadSurahNumber;
  final String? mostReadSurahName;
  final int bestDayAyahs;
  final DateTime? bestDayDate;

  factory ReadingSummaryModel.fromMap(Map<dynamic, dynamic> map) {
    return ReadingSummaryModel(
      readingMinutes: map['readingMinutes'] as int? ?? 0,
      pagesRead: map['pagesRead'] as int? ?? 0,
      ayahsRead: map['ayahsRead'] as int? ?? 0,
      sessions: map['sessions'] as int? ?? 0,
      activeDays: map['activeDays'] as int? ?? 0,
      averageSessionMinutes: map['averageSessionMinutes'] as int? ?? 0,
      mostReadSurahNumber: map['mostReadSurahNumber'] as int?,
      mostReadSurahName: map['mostReadSurahName'] as String?,
      bestDayAyahs: map['bestDayAyahs'] as int? ?? 0,
      bestDayDate: map['bestDayDate'] != null
          ? DateTime.parse(map['bestDayDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'readingMinutes': readingMinutes,
        'pagesRead': pagesRead,
        'ayahsRead': ayahsRead,
        'sessions': sessions,
        'activeDays': activeDays,
        'averageSessionMinutes': averageSessionMinutes,
        if (mostReadSurahNumber != null)
          'mostReadSurahNumber': mostReadSurahNumber,
        if (mostReadSurahName != null) 'mostReadSurahName': mostReadSurahName,
        'bestDayAyahs': bestDayAyahs,
        if (bestDayDate != null) 'bestDayDate': bestDayDate!.toIso8601String(),
      };
}

/// Daily activity count for heatmap-style charts.
class DailyActivityModel {
  const DailyActivityModel({
    required this.date,
    required this.ayahsRead,
    required this.minutes,
    required this.sessions,
  });

  final DateTime date;
  final int ayahsRead;
  final int minutes;
  final int sessions;

  factory DailyActivityModel.fromMap(Map<dynamic, dynamic> map) {
    return DailyActivityModel(
      date: DateTime.parse(map['date'] as String),
      ayahsRead: map['ayahsRead'] as int? ?? 0,
      minutes: map['minutes'] as int? ?? 0,
      sessions: map['sessions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'ayahsRead': ayahsRead,
        'minutes': minutes,
        'sessions': sessions,
      };
}
