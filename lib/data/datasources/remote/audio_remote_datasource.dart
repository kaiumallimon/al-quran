import '../../../core/exceptions/app_exceptions.dart';
import '../../models/audio_track_model.dart';
import '../remote/quran_api_client.dart';

/// Remote data source for Quran audio from alquran.cloud.
class AudioRemoteDataSource {
  AudioRemoteDataSource(this._client);

  final QuranApiClient _client;

  Future<List<AudioTrackModel>> fetchSurahAudio(
    int surahNumber,
    String reciterId,
  ) async {
    final response = await _client.get('/surah/$surahNumber/$reciterId');
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException('Invalid audio response');
    }

    final ayahs = data['ayahs'] as List? ?? [];
    final surahEnglishName =
        data['englishName'] as String? ?? 'Surah $surahNumber';

    return ayahs.map((item) {
      final map = item as Map<String, dynamic>;
      final audio = map['audio'] as String?;
      if (audio == null || audio.isEmpty) {
        throw AudioException(
          'Audio unavailable for ayah ${map['numberInSurah']}',
        );
      }

      return AudioTrackModel(
        surahNumber: surahNumber,
        numberInSurah: map['numberInSurah'] as int,
        globalAyahNumber: map['number'] as int,
        audioUrl: audio,
        surahEnglishName: surahEnglishName,
        reciterId: reciterId,
      );
    }).toList();
  }

  Future<AudioTrackModel> fetchAyahAudio(
    int globalAyahNumber,
    String reciterId, {
    required int surahNumber,
    required int numberInSurah,
    required String surahEnglishName,
  }) async {
    final response =
        await _client.get('/ayah/$globalAyahNumber/$reciterId');
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ApiException('Invalid ayah audio response');
    }

    final audio = data['audio'] as String?;
    if (audio == null || audio.isEmpty) {
      throw const AudioException('Audio unavailable for this ayah');
    }

    return AudioTrackModel(
      surahNumber: surahNumber,
      numberInSurah: numberInSurah,
      globalAyahNumber: globalAyahNumber,
      audioUrl: audio,
      surahEnglishName: surahEnglishName,
      reciterId: reciterId,
    );
  }
}
