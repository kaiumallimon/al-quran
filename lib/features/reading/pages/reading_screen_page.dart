import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../data/models/reading_mode.dart';
import '../../tracking/providers/tracking_provider.dart';
import '../providers/reading_provider.dart';
import '../widgets/ayah_card.dart';
import '../widgets/reading_bottom_bar.dart';
import '../widgets/reading_controls_bar.dart';
import '../widgets/surah_header.dart';

/// Main Quran reading screen for a single surah.
class ReadingScreenPage extends StatefulWidget {
  const ReadingScreenPage({
    super.key,
    required this.surahNumber,
    this.initialAyah,
  });

  final int surahNumber;
  final int? initialAyah;

  @override
  State<ReadingScreenPage> createState() => _ReadingScreenPageState();
}

class _ReadingScreenPageState extends State<ReadingScreenPage> {
  final _scrollController = ScrollController();
  final _ayahKeys = <int, GlobalKey>{};
  int? _lastSavedAyah;
  bool _hasScrolledToTarget = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReadingProvider>().openSurah(
            widget.surahNumber,
            initialAyah: widget.initialAyah,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final provider = context.read<ReadingProvider>();
    final surah = provider.currentSurah;
    if (surah == null) return;

    // Estimate visible ayah from scroll offset for progress saving
    const estimatedHeight = 180.0;
    final index = (_scrollController.offset / estimatedHeight).floor();
    final clampedIndex = index.clamp(0, surah.ayahs.length - 1);
    final ayahNumber = surah.ayahs[clampedIndex].numberInSurah;

    if (_lastSavedAyah != ayahNumber) {
      _lastSavedAyah = ayahNumber;
      provider.updateProgress(ayahNumber);
      context.read<TrackingProvider>().recordReadingActivity(
            surahNumber: surah.surah.number,
            ayahsRead: 1,
          );
    }
  }

  void _scrollToAyah(int ayahNumber) {
    final key = _ayahKeys[ayahNumber];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
      return;
    }

    // Approximate jump for unbuilt items
    const estimatedHeight = 180.0;
    final offset = (ayahNumber - 1) * estimatedHeight;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final retryKey = _ayahKeys[ayahNumber];
      if (retryKey?.currentContext != null) {
        Scrollable.ensureVisible(
          retryKey!.currentContext!,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFocusMode = context.select<ReadingProvider, bool>(
      (p) => p.preferences.readingMode == ReadingMode.readingFocus,
    );

    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final surahReading = provider.currentSurah;

        if (provider.readingStatus == SurahReadingStatus.loading ||
            surahReading == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Surah ${widget.surahNumber}')),
            body: _buildLoading(),
          );
        }

        if (provider.readingStatus == SurahReadingStatus.error) {
          return Scaffold(
            appBar: AppBar(title: Text('Surah ${widget.surahNumber}')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ErrorStateWidget(
                  message: provider.readingError ?? 'Something went wrong',
                  onRetry: () => provider.openSurah(
                    widget.surahNumber,
                    initialAyah: widget.initialAyah,
                  ),
                ),
              ),
            ),
          );
        }

        if (!_hasScrolledToTarget && provider.scrollToAyah != null) {
          _hasScrolledToTarget = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToAyah(provider.scrollToAyah!);
            provider.clearScrollTarget();
          });
        }

        final surah = surahReading.surah;
        final ayahs = surahReading.ayahs;
        final prefs = provider.preferences;

        return Scaffold(
          appBar: isFocusMode
              ? null
              : AppBar(
                  title: Text(surah.englishName),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.fullscreen),
                      onPressed: () =>
                          provider.setReadingMode(ReadingMode.readingFocus),
                      tooltip: 'Reading focus',
                    ),
                  ],
                ),
          floatingActionButton: isFocusMode
              ? FloatingActionButton.small(
                  onPressed: () =>
                      provider.setReadingMode(ReadingMode.normal),
                  tooltip: 'Exit focus mode',
                  child: const Icon(Icons.fullscreen_exit),
                )
              : null,
          body: Column(
            children: [
              if (!isFocusMode) const ReadingControlsBar(),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.maxReadingWidth,
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      itemCount: ayahs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return SurahHeader(surah: surah);
                        }

                        final ayah = ayahs[index - 1];
                        _ayahKeys.putIfAbsent(
                          ayah.numberInSurah,
                          () => GlobalKey(),
                        );

                        return AyahCard(
                          itemKey: _ayahKeys[ayah.numberInSurah],
                          ayah: ayah,
                          preferences: prefs,
                          surahEnglishName: surah.englishName,
                          isHighlighted:
                              provider.highlightedAyah == ayah.numberInSurah,
                          isFocusMode: isFocusMode,
                          onTap: () => provider.setHighlightedAyah(
                            ayah.numberInSurah,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              ReadingBottomBar(surahNumber: surah.number),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(height: 100),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(height: 160),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(height: 160),
      ],
    );
  }
}
