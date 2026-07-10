/// Repeat behaviour for Quran audio playback.
enum AudioRepeatMode {
  none,
  ayah,
  surah;

  String get label {
    switch (this) {
      case AudioRepeatMode.none:
        return 'Off';
      case AudioRepeatMode.ayah:
        return 'Repeat ayah';
      case AudioRepeatMode.surah:
        return 'Repeat surah';
    }
  }

  static AudioRepeatMode fromString(String value) {
    return AudioRepeatMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AudioRepeatMode.none,
    );
  }
}
