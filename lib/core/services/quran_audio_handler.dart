import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/models/audio_repeat_mode.dart';
import '../../data/models/audio_track_model.dart';

/// Background-capable audio handler for Quran recitation playback.
class QuranAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  QuranAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.currentIndexStream.listen((index) {
      if (index == null || index >= _tracks.length) return;
      _currentIndex = index;
      final track = _tracks[index];
      mediaItem.add(_mediaItemForTrack(track));
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final List<AudioTrackModel> _tracks = [];
  int _currentIndex = 0;
  AudioRepeatMode _repeatMode = AudioRepeatMode.none;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  AudioTrackModel? get currentTrack =>
      _currentIndex >= 0 && _currentIndex < _tracks.length
          ? _tracks[_currentIndex]
          : null;

  List<AudioTrackModel> get tracks => List.unmodifiable(_tracks);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> setPlaybackRepeatMode(AudioRepeatMode mode) async {
    _repeatMode = mode;
    switch (mode) {
      case AudioRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
      case AudioRepeatMode.ayah:
        await _player.setLoopMode(LoopMode.one);
      case AudioRepeatMode.surah:
        await _player.setLoopMode(LoopMode.all);
    }
  }

  Future<void> loadTracks(
    List<AudioTrackModel> tracks,
    List<String> resolvedUrls, {
    int startIndex = 0,
  }) async {
    if (tracks.isEmpty || tracks.length != resolvedUrls.length) {
      throw ArgumentError('Tracks and URLs must match');
    }

    _tracks
      ..clear()
      ..addAll(tracks);

    final mediaItems = tracks.map(_mediaItemForTrack).toList();
    queue.add(mediaItems);

    final sources = resolvedUrls
        .map((url) => AudioSource.uri(Uri.parse(url)))
        .toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: startIndex.clamp(0, tracks.length - 1),
    );

    _currentIndex = startIndex.clamp(0, tracks.length - 1);
    mediaItem.add(mediaItems[_currentIndex]);
    await setPlaybackRepeatMode(_repeatMode);
  }

  Future<void> seekToAyah(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    await _player.seek(Duration.zero, index: index);
    _currentIndex = index;
    mediaItem.add(_mediaItemForTrack(_tracks[index]));
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _tracks.clear();
    _currentIndex = 0;
    queue.add([]);
    await super.stop();
  }

  MediaItem _mediaItemForTrack(AudioTrackModel track) {
    return MediaItem(
      id: track.cacheKey,
      title: track.reference,
      artist: 'Quran Recitation',
      album: track.surahEnglishName,
      extras: track.toMap(),
    );
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _mapProcessingState(_player.processingState),
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
    }
  }
}

/// Combines playback streams for UI consumption.
Stream<(Duration position, Duration? duration, bool playing, int? index)>
    combinePlaybackStreams(QuranAudioHandler handler) {
  return Rx.combineLatest4(
    handler.positionStream,
    handler.durationStream,
    handler.playingStream,
    handler.currentIndexStream,
    (position, duration, playing, index) =>
        (position, duration, playing, index),
  );
}
