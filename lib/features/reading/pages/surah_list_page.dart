import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/surah_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../pages/reading_screen_page.dart';
import '../providers/reading_provider.dart';

/// Browse and select a surah to read.
class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReadingProvider>();
      if (provider.listStatus == SurahListStatus.initial) {
        provider.loadSurahList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Quran'),
      ),
      body: Consumer<ReadingProvider>(
        builder: (context, provider, _) {
          if (provider.listStatus == SurahListStatus.loading &&
              provider.surahs.isEmpty) {
            return _buildSkeleton();
          }

          if (provider.listStatus == SurahListStatus.error &&
              provider.surahs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ErrorStateWidget(
                  message: provider.listError ?? 'Something went wrong',
                  onRetry: provider.loadSurahList,
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search surah by name or number',
                  leading: const Icon(Icons.search),
                  onChanged: provider.setSearchQuery,
                  trailing: provider.searchQuery.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          ),
                        ]
                      : null,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.loadSurahList,
                  child: provider.filteredSurahs.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            Center(child: Text('No surahs found')),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          itemCount: provider.filteredSurahs.length,
                          itemBuilder: (context, index) {
                            final surah = provider.filteredSurahs[index];
                            return SurahListTile(
                              surah: surah,
                              onTap: () => _openSurah(context, surah.number),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 8,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: SkeletonLoader(height: 72),
      ),
    );
  }

  void _openSurah(BuildContext context, int surahNumber) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReadingScreenPage(surahNumber: surahNumber),
      ),
    );
  }
}

/// Single row in the surah list.
class SurahListTile extends StatelessWidget {
  const SurahListTile({
    super.key,
    required this.surah,
    required this.onTap,
  });

  final SurahModel surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    '${surah.number}',
                    style: AppTypography.body(context).copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.englishName,
                        style: AppTypography.body(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        surah.englishNameTranslation,
                        style: AppTypography.caption(context).copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      surah.name,
                      style: AppTypography.arabic(
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      '${surah.numberOfAyahs} ayahs · ${surah.revelationType}',
                      style: AppTypography.small(context).copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
