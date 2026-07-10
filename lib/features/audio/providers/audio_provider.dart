import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/services/quran_audio_handler.dart';
import '../../../data/models/audio_preferences_model.dart';
import '../../../data/models/audio_repeat_mode.dart';
import '../../../data/models/audio_track_model.dart';
import '../../../data/models/reciter_model.dart';
import '../../../data/repositories/audio_repository.dart';

enum AudioStatus { idle, loading, playing, paused, error }

/// View model for Quran audio playback.
class AudioProvider extends ChangeNotifier {
  AudioProvider({required AudioRepository repository})
      : _repository = repository {
    _initStreams();
  }

  final AudioRepository _repository;
  QuranAudioHandler get _handler => _repository.handler;

  StreamSubscription<(Duration, Duration?, bool, int?)>? _playbackSub;
  Timer? _sleepTimer;

  AudioStatus _status = AudioStatus.idle;
  AudioPreferencesModel _preferences = const AudioPreferencesModel();
  String? _errorMessage;
  Duration _position = Duration.zero;
  Duration? _duration;
  bool _isPlaying = false;
  int? _currentIndex;
  bool _isExpanded = false;
  bool _isBuffering = false;

  AudioStatus get status => _status;
  AudioPreferencesModel get preferences => _preferences;
  String? get errorMessage => _errorMessage;
  Duration get position => _position;
  Duration? get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get isExpanded => _isExpanded;
  bool get isBuffering => _isBuffering;
  bool get hasActiveTrack => _handler.currentTrack != null;

  AudioTrackModel? get currentTrack => _handler.currentTrack;
  List<AudioTrackModel> get queue => _handler.tracks;
  List<ReciterModel> get reciters => _repository.getReciters();

  ReciterModel? get currentReciter =>
      ReciterModel.findById(_preferences.preferredReciter);

  double get progress {
    if (_duration == null || _duration!.inMilliseconds == 0) return 0;
    return _position.inMilliseconds / _duration!.inMilliseconds;
  }

  Future<void> loadPreferences() async {
    _preferences = await _repository.getPreferences();
    notifyListeners();
  }

  Future<void> playSurah(
    int surahNumber, {
    int startAyah = 1,
    String? surahEnglishName,
  }) async {
    await _startPlayback(() => _repository.playSurah(
          surahNumber,
          startAyah: startAyah,
        ));
  }

  Future<void> playAyah({
    required int surahNumber,
    required int numberInSurah,
    required int globalAyahNumber,
    required String surahEnglishName,
  }) async {
    await _startPlayback(
      () => _repository.playAyah(
        surahNumber: surahNumber,
        numberInSurah: numberInSurah,
        globalAyahNumber: globalAyahNumber,
        surahEnglishName: surahEnglishName,
      ),
    );
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _repository.pause();
      _status = AudioStatus.paused;
    } else if (_handler.currentTrack != null) {
      await _repository.resume();
      _status = AudioStatus.playing;
    }
    notifyListeners();
  }

  Future<void> pause() async {
    await _repository.pause();
    _status = AudioStatus.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    await _repository.resume();
    _status = AudioStatus.playing;
    notifyListeners();
  }

  Future<void> stop() async {
    await _repository.stop();
    _status = AudioStatus.idle;
    _position = Duration.zero;
    _duration = null;
    _currentIndex = null;
    _cancelSleepTimer();
    notifyListeners();
  }

  Future<void> seek(Duration position) => _repository.seek(position);

  Future<void> skipToNext() => _repository.skipToNext();

  Future<void> skipToPrevious() => _repository.skipToPrevious();

  Future<void> seekToAyah(int index) => _repository.seekToAyah(index);

  Future<void> setSpeed(double speed) async {
    await _repository.setSpeed(speed);
    _preferences = _preferences.copyWith(playbackSpeed: speed);
    notifyListeners();
  }

  Future<void> setRepeatMode(AudioRepeatMode mode) async {
    await _repository.setRepeatMode(mode);
    _preferences = _preferences.copyWith(repeatMode: mode);
    notifyListeners();
  }

  Future<void> changeReciter(String reciterId) async {
    _preferences = _preferences.copyWith(preferredReciter: reciterId);
    await _repository.changeReciter(reciterId);
    notifyListeners();
  }

  Future<void> downloadCurrentSurah() async {
    final track = currentTrack;
    if (track == null) return;
    await _repository.downloadSurahAudio(track.surahNumber);
  }

  Future<bool> isCurrentSurahDownloaded() async {
    final track = currentTrack;
    if (track == null) return false;
    return _repository.isSurahDownloaded(track.surahNumber);
  }

  void setExpanded(bool expanded) {
    _isExpanded = expanded;
    notifyListeners();
  }

  void startSleepTimer(int minutes) {
    _cancelSleepTimer();
    _preferences = _preferences.copyWith(sleepTimerMinutes: minutes);
    if (minutes <= 0) {
      notifyListeners();
      return;
    }

    _sleepTimer = Timer(Duration(minutes: minutes), () async {
      await pause();
      _preferences = _preferences.copyWith(sleepTimerMinutes: 0);
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> _startPlayback(Future<void> Function() action) async {
    _status = AudioStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _status = AudioStatus.playing;
    } catch (_) {
      _errorMessage = 'Unable to play audio. Please check your connection.';
      _status = AudioStatus.error;
    }

    notifyListeners();
  }

  void _initStreams() {
    _playbackSub = combinePlaybackStreams(_handler).listen((state) {
      final (position, duration, playing, index) = state;
      _position = position;
      _duration = duration;
      _isPlaying = playing;
      _currentIndex = index;

      if (playing) {
        _status = AudioStatus.playing;
      } else if (_handler.currentTrack != null && _status != AudioStatus.loading) {
        _status = AudioStatus.paused;
      }

      notifyListeners();
    });

    _handler.playerStateStream.listen((playerState) {
      _isBuffering = playerState.processingState == ProcessingState.buffering ||
          playerState.processingState == ProcessingState.loading;
      notifyListeners();
    });
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  @override
  void dispose() {
    _playbackSub?.cancel();
    _cancelSleepTimer();
    super.dispose();
  }
}
