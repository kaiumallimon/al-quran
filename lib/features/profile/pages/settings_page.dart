import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../data/models/app_settings_model.dart';
import '../../../core/di/service_locator.dart';
import '../../audio/providers/audio_provider.dart';
import '../../audio/widgets/reciter_selection_sheet.dart';
import '../../notifications/widgets/notification_settings_sheet.dart';
import '../../reading/providers/reading_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_tile.dart';

/// Application settings with appearance, reading, audio, and privacy options.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _audioCacheBytes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<SettingsProvider>().loadSettings();
      await _loadCacheSize();
    });
  }

  Future<void> _loadCacheSize() async {
    final bytes =
        await ServiceLocator.instance.audioRepository.getAudioCacheSizeBytes();
    if (mounted) setState(() => _audioCacheBytes = bytes);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer3<SettingsProvider, ReadingProvider, AudioProvider>(
        builder: (context, settings, reading, audio, _) {
          final appSettings = settings.settings;
          final readingPrefs = reading.preferences;
          final audioPrefs = audio.preferences;

          return ListView(
            children: [
              SettingsSection(
                title: 'Appearance',
                children: [
                  SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    subtitle: appSettings.themeMode.label,
                    onTap: () => _showThemePicker(context, settings),
                  ),
                ],
              ),
              SettingsSection(
                title: 'Reading',
                children: [
                  SettingsTile(
                    icon: Icons.format_size,
                    title: 'Arabic font size',
                    subtitle: readingPrefs.arabicFontSize.toStringAsFixed(0),
                    trailing: SizedBox(
                      width: 160,
                      child: Slider(
                        value: readingPrefs.arabicFontSize,
                        min: 20,
                        max: 40,
                        divisions: 20,
                        onChanged: (value) => reading.setArabicFontSize(value),
                      ),
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.text_fields,
                    title: 'Translation font size',
                    subtitle:
                        readingPrefs.translationFontSize.toStringAsFixed(0),
                    trailing: SizedBox(
                      width: 160,
                      child: Slider(
                        value: readingPrefs.translationFontSize,
                        min: 12,
                        max: 24,
                        divisions: 12,
                        onChanged: (value) =>
                            reading.setTranslationFontSize(value),
                      ),
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.height,
                    title: 'Line height',
                    subtitle: readingPrefs.lineHeight.toStringAsFixed(1),
                    trailing: SizedBox(
                      width: 160,
                      child: Slider(
                        value: readingPrefs.lineHeight,
                        min: 1.4,
                        max: 2.4,
                        divisions: 10,
                        onChanged: (value) => reading.updatePreferences(
                          readingPrefs.copyWith(lineHeight: value),
                        ),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.play_circle_outline),
                    title: const Text('Auto resume reading'),
                    value: appSettings.autoResumeReading,
                    onChanged: settings.toggleAutoResume,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.light_mode_outlined),
                    title: const Text('Keep screen awake'),
                    value: appSettings.keepScreenAwake,
                    onChanged: settings.toggleKeepScreenAwake,
                  ),
                ],
              ),
              SettingsSection(
                title: 'Audio',
                children: [
                  SettingsTile(
                    icon: Icons.record_voice_over_outlined,
                    title: 'Preferred reciter',
                    subtitle: audio.currentReciter?.name ??
                        audioPrefs.preferredReciter,
                    onTap: () => showReciterSelectionSheet(context),
                  ),
                  SettingsTile(
                    icon: Icons.speed,
                    title: 'Playback speed',
                    subtitle: '${audioPrefs.playbackSpeed}x',
                    trailing: SizedBox(
                      width: 160,
                      child: Slider(
                        value: audioPrefs.playbackSpeed,
                        min: 0.75,
                        max: 2.0,
                        divisions: 5,
                        label: '${audioPrefs.playbackSpeed}x',
                        onChanged: (value) => audio.setSpeed(value),
                      ),
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.repeat,
                    title: 'Repeat mode',
                    subtitle: audioPrefs.repeatMode.label,
                    onTap: () {},
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.headphones_outlined),
                    title: const Text('Background playback'),
                    value: audioPrefs.backgroundPlayback,
                    onChanged: (value) async {
                      final updated =
                          audioPrefs.copyWith(backgroundPlayback: value);
                      await ServiceLocator.instance.audioRepository
                          .savePreferences(updated);
                      await audio.loadPreferences();
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'Notifications',
                children: [
                  SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notification preferences',
                    onTap: () => NotificationSettingsSheet.show(context),
                  ),
                ],
              ),
              SettingsSection(
                title: 'Storage',
                children: [
                  SettingsTile(
                    icon: Icons.audio_file_outlined,
                    title: 'Audio cache',
                    subtitle: _formatBytes(_audioCacheBytes),
                  ),
                  SettingsTile(
                    icon: Icons.delete_outline,
                    title: 'Clear audio cache',
                    onTap: () => _confirmClearAudioCache(context),
                  ),
                ],
              ),
              SettingsSection(
                title: 'Privacy',
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.analytics_outlined),
                    title: const Text('Analytics'),
                    subtitle: const Text('Opt-in when Firebase is enabled'),
                    value: appSettings.analyticsEnabled,
                    onChanged: settings.toggleAnalytics,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.bug_report_outlined),
                    title: const Text('Crash reports'),
                    value: appSettings.crashReportsEnabled,
                    onChanged: settings.toggleCrashReports,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.cloud_sync_outlined),
                    title: const Text('Cloud sync'),
                    subtitle: const Text('Back up bookmarks, notes, and progress'),
                    value: appSettings.syncEnabled,
                    onChanged: (value) async {
                      final message = await settings.toggleSync(value);
                      if (message != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'Accessibility',
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.text_increase),
                    title: const Text('Dynamic text'),
                    value: appSettings.dynamicText,
                    onChanged: settings.toggleDynamicText,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.motion_photos_off_outlined),
                    title: const Text('Reduce motion'),
                    value: appSettings.reduceMotion,
                    onChanged: settings.toggleReduceMotion,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.contrast),
                    title: const Text('High contrast'),
                    value: appSettings.highContrast,
                    onChanged: settings.toggleHighContrast,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.format_textdirection_r_to_l),
                    title: const Text('RTL preview'),
                    value: appSettings.rtlPreview,
                    onChanged: settings.toggleRtlPreview,
                  ),
                ],
              ),
              SettingsSection(
                title: 'About',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        const AppLogo(size: 72, elevation: 2),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppConstants.appName,
                          style: AppTypography.title(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Your offline-first Quran reading companion.',
                          style: AppTypography.small(context).copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SettingsTile(
                    icon: Icons.info_outline,
                    title: 'App version',
                    subtitle: '1.0.0',
                  ),
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy policy',
                    onTap: () {},
                  ),
                  SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of service',
                    onTap: () {},
                  ),
                ],
              ),
              if (kDebugMode)
                SettingsSection(
                  title: 'Developer',
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.developer_mode),
                      title: const Text('Debug mode'),
                      value: appSettings.debugMode,
                      onChanged: (value) => settings.updateSettings(
                        appSettings.copyWith(debugMode: value),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }

  void _showThemePicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values
              .map(
                (mode) => ListTile(
                  title: Text(mode.label),
                  trailing: settings.settings.themeMode == mode
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    settings.setThemeMode(mode);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _confirmClearAudioCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear audio cache?'),
        content: const Text(
          'Downloaded recitations will be removed. You can download them again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ServiceLocator.instance.audioRepository.clearAudioCache();
    await _loadCacheSize();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio cache cleared')),
      );
    }
  }
}
