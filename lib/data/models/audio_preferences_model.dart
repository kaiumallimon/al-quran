import 'audio_repeat_mode.dart';

/// Persisted audio playback preferences.
class AudioPreferencesModel {
  const AudioPreferencesModel({
    this.preferredReciter = 'ar.alafasy',
    this.playbackSpeed = 1.0,
    this.autoContinue = true,
    this.repeatMode = AudioRepeatMode.none,
    this.backgroundPlayback = true,
    this.sleepTimerMinutes = 0,
  });

  final String preferredReciter;
  final double playbackSpeed;
  final bool autoContinue;
  final AudioRepeatMode repeatMode;
  final bool backgroundPlayback;
  final int sleepTimerMinutes;

  AudioPreferencesModel copyWith({
    String? preferredReciter,
    double? playbackSpeed,
    bool? autoContinue,
    AudioRepeatMode? repeatMode,
    bool? backgroundPlayback,
    int? sleepTimerMinutes,
  }) {
    return AudioPreferencesModel(
      preferredReciter: preferredReciter ?? this.preferredReciter,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      autoContinue: autoContinue ?? this.autoContinue,
      repeatMode: repeatMode ?? this.repeatMode,
      backgroundPlayback: backgroundPlayback ?? this.backgroundPlayback,
      sleepTimerMinutes: sleepTimerMinutes ?? this.sleepTimerMinutes,
    );
  }

  factory AudioPreferencesModel.fromMap(Map<dynamic, dynamic> map) {
    return AudioPreferencesModel(
      preferredReciter: map['preferredReciter'] as String? ?? 'ar.alafasy',
      playbackSpeed: (map['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      autoContinue: map['autoContinue'] as bool? ?? true,
      repeatMode: AudioRepeatMode.fromString(
        map['repeatMode'] as String? ?? 'none',
      ),
      backgroundPlayback: map['backgroundPlayback'] as bool? ?? true,
      sleepTimerMinutes: map['sleepTimerMinutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'preferredReciter': preferredReciter,
        'playbackSpeed': playbackSpeed,
        'autoContinue': autoContinue,
        'repeatMode': repeatMode.name,
        'backgroundPlayback': backgroundPlayback,
        'sleepTimerMinutes': sleepTimerMinutes,
      };
}
