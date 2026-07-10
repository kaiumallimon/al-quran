import 'package:http/http.dart' as http;

import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/quran_audio_handler.dart';
import '../../core/utils/logger.dart';
import '../datasources/local/audio_local_datasource.dart';
import '../datasources/remote/audio_remote_datasource.dart';
import '../models/audio_preferences_model.dart';
import '../models/audio_repeat_mode.dart';
import '../models/audio_track_model.dart';
import '../models/reciter_model.dart';

/// Repository for Quran audio playback, caching, and preferences.
class AudioRepository {
  AudioRepository({
    required AudioLocalDataSource local,
    required AudioRemoteDataSource remote,
    required QuranAudioHandler handler,
  })  : _local = local,
        _remote = remote,
        _handler = handler;

  final AudioLocalDataSource _local;
  final AudioRemoteDataSource _remote;
  final QuranAudioHandler _handler;
  static const _tag = 'AudioRepository';

  QuranAudioHandler get handler => _handler;

  Future<AudioPreferencesModel> getPreferences() => _local.getPreferences();

  Future<void> savePreferences(AudioPreferencesModel prefs) async {
    await _local.savePreferences(prefs);
    await _handler.setSpeed(prefs.playbackSpeed);
    await _handler.setRepeatMode(prefs.repeatMode);
  }

  List<ReciterModel> getReciters() => ReciterModel.defaults;

  Future<void> playSurah(
    int surahNumber, {
    String? reciterId,
    int startAyah = 1,
  }) async {
    final prefs = await getPreferences();
    final reciter = reciterId ?? prefs.preferredReciter;
    final tracks = await _getSurahTracks(surahNumber, reciter);
    final startIndex = (startAyah - 1).clamp(0, tracks.length - 1);
    await _loadAndPlay(tracks, startIndex: startIndex);
  }

  Future<void> playAyah({
    required int surahNumber,
    required int numberInSurah,
    required int globalAyahNumber,
    required String surahEnglishName,
    String? reciterId,
  }) async {
    final prefs = await getPreferences();
    final reciter = reciterId ?? prefs.preferredReciter;

    final track = await _resolveAyahTrack(
      surahNumber: surahNumber,
      numberInSurah: numberInSurah,
      globalAyahNumber: globalAyahNumber,
      surahEnglishName: surahEnglishName,
      reciterId: reciter,
    );

    await _loadAndPlay([track]);
  }

  Future<void> playQueue(List<AudioTrackModel> tracks, {int startIndex = 0}) {
    return _loadAndPlay(tracks, startIndex: startIndex);
  }

  Future<void> pause() => _handler.pause();

  Future<void> resume() => _handler.play();

  Future<void> stop() => _handler.stopPlayback();

  Future<void> seek(Duration position) => _handler.seek(position);

  Future<void> skipToNext() => _handler.skipToNext();

  Future<void> skipToPrevious() => _handler.skipToPrevious();

  Future<void> seekToAyah(int index) => _handler.seekToAyah(index);

  Future<void> setSpeed(double speed) async {
    await _handler.setSpeed(speed);
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(playbackSpeed: speed));
  }

  Future<void> setRepeatMode(AudioRepeatMode mode) async {
    await _handler.setRepeatMode(mode);
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(repeatMode: mode));
  }

  Future<void> changeReciter(String reciterId) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(preferredReciter: reciterId));

    final current = _handler.currentTrack;
    if (current != null) {
      await playSurah(
        current.surahNumber,
        reciterId: reciterId,
        startAyah: current.numberInSurah,
      );
    }
  }

  Future<void> downloadSurahAudio(int surahNumber, {String? reciterId}) async {
    final prefs = await getPreferences();
    final reciter = reciterId ?? prefs.preferredReciter;
    final tracks = await _getSurahTracks(surahNumber, reciter, fetchRemote: true);

    for (final track in tracks) {
      await _downloadTrack(track);
    }

    await _local.markSurahDownloaded(reciter, surahNumber);
  }

  Future<void> deleteSurahAudio(int surahNumber, {String? reciterId}) async {
    final prefs = await getPreferences();
    final reciter = reciterId ?? prefs.preferredReciter;
    await _local.deleteSurahAudio(reciter, surahNumber);
  }

  Future<bool> isSurahDownloaded(int surahNumber, {String? reciterId}) async {
    final prefs = await getPreferences();
    final reciter = reciterId ?? prefs.preferredReciter;
    return _local.isSurahDownloaded(reciter, surahNumber);
  }

  Future<int> getAudioCacheSizeBytes() => _local.getAudioCacheSizeBytes();

  Future<void> clearAudioCache() => _local.clearAudioCache();

  Future<List<AudioTrackModel>> _getSurahTracks(
    int surahNumber,
    String reciterId, {
    bool fetchRemote = false,
  }) async {
    try {
      final tracks = await _remote.fetchSurahAudio(surahNumber, reciterId);
      for (final track in tracks) {
        await _local.cacheTrackMetadata(track);
      }
      return tracks;
    } catch (e) {
      AppLogger.warning(_tag, 'Remote surah audio fetch failed: $e');
      if (!fetchRemote) rethrow;

      final cachedKeys = await _local.getDownloadedSurahKeys(reciterId);
      if (!cachedKeys.contains('$surahNumber')) rethrow;

      final result = <AudioTrackModel>[];
      for (var ayah = 1; ayah <= 286; ayah++) {
        final key = '${reciterId}_${surahNumber}_$ayah';
        final meta = await _local.getTrackMetadata(key);
        if (meta != null) result.add(meta);
      }
      if (result.isEmpty) rethrow;
      return result;
    }
  }

  Future<AudioTrackModel> _resolveAyahTrack({
    required int surahNumber,
    required int numberInSurah,
    required int globalAyahNumber,
    required String surahEnglishName,
    required String reciterId,
  }) async {
    final cacheKey = '${reciterId}_${surahNumber}_$numberInSurah';
    final cached = await _local.getTrackMetadata(cacheKey);
    if (cached != null) return cached;

    final track = await _remote.fetchAyahAudio(
      globalAyahNumber,
      reciterId,
      surahNumber: surahNumber,
      numberInSurah: numberInSurah,
      surahEnglishName: surahEnglishName,
    );
    await _local.cacheTrackMetadata(track);
    return track;
  }

  Future<void> _loadAndPlay(
    List<AudioTrackModel> tracks, {
    int startIndex = 0,
  }) async {
    final urls = await Future.wait(tracks.map(_resolvePlaybackUrl));
    await _handler.loadTracks(tracks, urls, startIndex: startIndex);
    await _handler.play();
  }

  Future<String> _resolvePlaybackUrl(AudioTrackModel track) async {
    final cachedPath = await _local.getCachedFilePath(track.cacheKey);
    if (cachedPath != null) return cachedPath;
    return track.audioUrl;
  }

  Future<void> _downloadTrack(AudioTrackModel track) async {
    final existing = await _local.getCachedFilePath(track.cacheKey);
    if (existing != null) return;

    final response = await http.get(Uri.parse(track.audioUrl));
    if (response.statusCode != 200) {
      throw AudioException('Failed to download ${track.reference}');
    }

    await _local.saveCachedFile(track.cacheKey, response.bodyBytes);
    await _local.cacheTrackMetadata(track);
  }
}
