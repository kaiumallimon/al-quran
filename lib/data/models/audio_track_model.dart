/// A single ayah audio track for playback or caching.
class AudioTrackModel {
  const AudioTrackModel({
    required this.surahNumber,
    required this.numberInSurah,
    required this.globalAyahNumber,
    required this.audioUrl,
    required this.surahEnglishName,
    this.reciterId = 'ar.alafasy',
  });

  final int surahNumber;
  final int numberInSurah;
  final int globalAyahNumber;
  final String audioUrl;
  final String surahEnglishName;
  final String reciterId;

  String get cacheKey => '${reciterId}_${surahNumber}_$numberInSurah';

  String get reference => '$surahEnglishName $surahNumber:$numberInSurah';

  AudioTrackModel copyWith({
    int? surahNumber,
    int? numberInSurah,
    int? globalAyahNumber,
    String? audioUrl,
    String? surahEnglishName,
    String? reciterId,
  }) {
    return AudioTrackModel(
      surahNumber: surahNumber ?? this.surahNumber,
      numberInSurah: numberInSurah ?? this.numberInSurah,
      globalAyahNumber: globalAyahNumber ?? this.globalAyahNumber,
      audioUrl: audioUrl ?? this.audioUrl,
      surahEnglishName: surahEnglishName ?? this.surahEnglishName,
      reciterId: reciterId ?? this.reciterId,
    );
  }

  factory AudioTrackModel.fromMap(Map<dynamic, dynamic> map) {
    return AudioTrackModel(
      surahNumber: map['surahNumber'] as int,
      numberInSurah: map['numberInSurah'] as int,
      globalAyahNumber: map['globalAyahNumber'] as int,
      audioUrl: map['audioUrl'] as String,
      surahEnglishName: map['surahEnglishName'] as String? ?? '',
      reciterId: map['reciterId'] as String? ?? 'ar.alafasy',
    );
  }

  Map<String, dynamic> toMap() => {
        'surahNumber': surahNumber,
        'numberInSurah': numberInSurah,
        'globalAyahNumber': globalAyahNumber,
        'audioUrl': audioUrl,
        'surahEnglishName': surahEnglishName,
        'reciterId': reciterId,
      };
}
