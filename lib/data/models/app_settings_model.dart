/// Application theme mode preference.
enum AppThemeMode {
  system,
  light,
  dark,
  amoled;

  String get label {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.amoled:
        return 'AMOLED';
    }
  }

  static AppThemeMode fromString(String value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}

/// Persisted application settings across categories.
class AppSettingsModel {
  const AppSettingsModel({
    this.themeMode = AppThemeMode.system,
    this.arabicFont = 'Noto Naskh Arabic',
    this.keepScreenAwake = false,
    this.autoResumeReading = true,
    this.readingWidth = 720,
    this.analyticsEnabled = false,
    this.crashReportsEnabled = true,
    this.syncEnabled = true,
    this.reduceMotion = false,
    this.highContrast = false,
    this.dynamicText = true,
    this.screenReaderHints = true,
    this.rtlPreview = false,
    this.debugMode = false,
  });

  final AppThemeMode themeMode;
  final String arabicFont;
  final bool keepScreenAwake;
  final bool autoResumeReading;
  final double readingWidth;
  final bool analyticsEnabled;
  final bool crashReportsEnabled;
  final bool syncEnabled;
  final bool reduceMotion;
  final bool highContrast;
  final bool dynamicText;
  final bool screenReaderHints;
  final bool rtlPreview;
  final bool debugMode;

  AppSettingsModel copyWith({
    AppThemeMode? themeMode,
    String? arabicFont,
    bool? keepScreenAwake,
    bool? autoResumeReading,
    double? readingWidth,
    bool? analyticsEnabled,
    bool? crashReportsEnabled,
    bool? syncEnabled,
    bool? reduceMotion,
    bool? highContrast,
    bool? dynamicText,
    bool? screenReaderHints,
    bool? rtlPreview,
    bool? debugMode,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      arabicFont: arabicFont ?? this.arabicFont,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      autoResumeReading: autoResumeReading ?? this.autoResumeReading,
      readingWidth: readingWidth ?? this.readingWidth,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportsEnabled: crashReportsEnabled ?? this.crashReportsEnabled,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      highContrast: highContrast ?? this.highContrast,
      dynamicText: dynamicText ?? this.dynamicText,
      screenReaderHints: screenReaderHints ?? this.screenReaderHints,
      rtlPreview: rtlPreview ?? this.rtlPreview,
      debugMode: debugMode ?? this.debugMode,
    );
  }

  factory AppSettingsModel.fromMap(Map<dynamic, dynamic> map) {
    return AppSettingsModel(
      themeMode: AppThemeMode.fromString(map['themeMode'] as String? ?? 'system'),
      arabicFont: map['arabicFont'] as String? ?? 'Noto Naskh Arabic',
      keepScreenAwake: map['keepScreenAwake'] as bool? ?? false,
      autoResumeReading: map['autoResumeReading'] as bool? ?? true,
      readingWidth: (map['readingWidth'] as num?)?.toDouble() ?? 720,
      analyticsEnabled: map['analyticsEnabled'] as bool? ?? false,
      crashReportsEnabled: map['crashReportsEnabled'] as bool? ?? true,
      syncEnabled: map['syncEnabled'] as bool? ?? true,
      reduceMotion: map['reduceMotion'] as bool? ?? false,
      highContrast: map['highContrast'] as bool? ?? false,
      dynamicText: map['dynamicText'] as bool? ?? true,
      screenReaderHints: map['screenReaderHints'] as bool? ?? true,
      rtlPreview: map['rtlPreview'] as bool? ?? false,
      debugMode: map['debugMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'themeMode': themeMode.name,
        'arabicFont': arabicFont,
        'keepScreenAwake': keepScreenAwake,
        'autoResumeReading': autoResumeReading,
        'readingWidth': readingWidth,
        'analyticsEnabled': analyticsEnabled,
        'crashReportsEnabled': crashReportsEnabled,
        'syncEnabled': syncEnabled,
        'reduceMotion': reduceMotion,
        'highContrast': highContrast,
        'dynamicText': dynamicText,
        'screenReaderHints': screenReaderHints,
        'rtlPreview': rtlPreview,
        'debugMode': debugMode,
      };
}
