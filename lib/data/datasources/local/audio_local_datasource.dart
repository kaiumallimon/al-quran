import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/hive_constants.dart';
import '../../models/audio_preferences_model.dart';
import '../../models/audio_track_model.dart';

/// Local storage for audio metadata and downloaded files.
class AudioLocalDataSource {
  Future<void> init() async {
    await Hive.openBox(HiveConstants.audioCacheBox);
    final dir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${dir.path}/audio_cache');
    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }
  }

  late Directory _cacheDir;

  Box get _box => Hive.box(HiveConstants.audioCacheBox);

  Future<AudioPreferencesModel> getPreferences() async {
    final map = _box.get('preferences') as Map?;
    if (map == null) return const AudioPreferencesModel();
    return AudioPreferencesModel.fromMap(map);
  }

  Future<void> savePreferences(AudioPreferencesModel prefs) async {
    await _box.put('preferences', prefs.toMap());
  }

  Future<void> cacheTrackMetadata(AudioTrackModel track) async {
    await _box.put('meta_${track.cacheKey}', track.toMap());
  }

  Future<AudioTrackModel?> getTrackMetadata(String cacheKey) async {
    final map = _box.get('meta_$cacheKey') as Map?;
    if (map == null) return null;
    return AudioTrackModel.fromMap(map);
  }

  Future<String?> getCachedFilePath(String cacheKey) async {
    final path = _box.get('file_$cacheKey') as String?;
    if (path == null) return null;
    if (await File(path).exists()) return path;
    await _box.delete('file_$cacheKey');
    return null;
  }

  Future<String> saveCachedFile(String cacheKey, List<int> bytes) async {
    final file = File('${_cacheDir.path}/$cacheKey.mp3');
    await file.writeAsBytes(bytes, flush: true);
    await _box.put('file_$cacheKey', file.path);
    return file.path;
  }

  Future<List<String>> getDownloadedSurahKeys(String reciterId) async {
    return _box.keys
        .whereType<String>()
        .where((key) => key.startsWith('surah_dl_${reciterId}_'))
        .map((key) => key.replaceFirst('surah_dl_${reciterId}_', ''))
        .toList();
  }

  Future<void> markSurahDownloaded(String reciterId, int surahNumber) async {
    await _box.put('surah_dl_${reciterId}_$surahNumber', DateTime.now().toIso8601String());
  }

  Future<bool> isSurahDownloaded(String reciterId, int surahNumber) async {
    return _box.containsKey('surah_dl_${reciterId}_$surahNumber');
  }

  Future<int> getAudioCacheSizeBytes() async {
    if (!await _cacheDir.exists()) return 0;
    var total = 0;
    await for (final entity in _cacheDir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<void> clearAudioCache() async {
    if (await _cacheDir.exists()) {
      await _cacheDir.delete(recursive: true);
      await _cacheDir.create(recursive: true);
    }

    final keys = _box.keys.whereType<String>().toList();
    for (final key in keys) {
      if (key.startsWith('file_') ||
          key.startsWith('meta_') ||
          key.startsWith('surah_dl_')) {
        await _box.delete(key);
      }
    }
  }

  Future<void> deleteSurahAudio(String reciterId, int surahNumber) async {
    final prefix = '${reciterId}_${surahNumber}_';
    final keys = _box.keys.whereType<String>().toList();
    for (final key in keys) {
      if (key.startsWith('file_$prefix') || key.startsWith('meta_$prefix')) {
        final path = _box.get(key) as String?;
        if (path != null) {
          final file = File(path);
          if (await file.exists()) await file.delete();
        }
        await _box.delete(key);
      }
    }
    await _box.delete('surah_dl_${reciterId}_$surahNumber');
  }
}
