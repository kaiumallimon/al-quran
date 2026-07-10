import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/reading_navigation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../data/models/search_result_model.dart';
import '../providers/search_provider.dart';
import '../widgets/recent_searches_section.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/search_suggestions_section.dart';

/// Main search screen for finding verses and surahs.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<SearchProvider>();
      await provider.initialize();
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        provider.setQuery(widget.initialQuery!);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, provider, _) {
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
                  controller: _controller,
                  focusNode: _focusNode,
                  hintText: 'Search verses, surahs, keywords…',
                  leading: const Icon(Icons.search),
                  onChanged: provider.setQuery,
                  onSubmitted: provider.submitSearch,
                  trailing: provider.query.isNotEmpty
                      ? [
                          if (provider.isRemoteLoading)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              provider.clearQuery();
                            },
                          ),
                        ]
                      : null,
                ),
              ),
              Expanded(
                child: _buildBody(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchProvider provider) {
    if (!provider.hasQuery) {
      return _buildIdleState(provider);
    }

    if (provider.status == SearchStatus.searching &&
        provider.results.isEmpty) {
      return _buildLoading();
    }

    if (provider.status == SearchStatus.error && provider.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ErrorStateWidget(
            message: provider.errorMessage ?? 'Search failed',
            onRetry: () => provider.submitSearch(provider.query),
          ),
        ),
      );
    }

    if (provider.status == SearchStatus.loaded && provider.results.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No results found',
        subtitle: 'Try different keywords or check spelling',
        actionLabel: 'Clear search',
        onAction: () {
          _controller.clear();
          provider.clearQuery();
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        SearchResultsList(
          results: provider.results,
          query: provider.query,
          isRemoteLoading: provider.isRemoteLoading,
          onResultTap: (result) => _openResult(context, provider, result),
        ),
      ],
    );
  }

  Widget _buildIdleState(SearchProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        EmptyStateWidget(
          icon: Icons.manage_search,
          title: 'Find any verse',
          subtitle:
              'Search across Arabic, English, Bangla, and surah names',
        ),
        const SizedBox(height: AppSpacing.lg),
        RecentSearchesSection(
          searches: provider.recentSearches,
          onTap: (query) {
            _controller.text = query;
            provider.selectSuggestion(query);
          },
          onClear: provider.clearHistory,
        ),
        const SizedBox(height: AppSpacing.lg),
        SearchSuggestionsSection(
          suggestions: provider.suggestions,
          onTap: (suggestion) {
            _controller.text = suggestion;
            provider.selectSuggestion(suggestion);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Popular searches',
          style: AppTypography.subtitle(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            'mercy',
            'patience',
            'guidance',
            'forgiveness',
            'paradise',
          ].map((term) {
            return ActionChip(
              label: Text(term),
              onPressed: () {
                _controller.text = term;
                provider.selectSuggestion(term);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(height: 100),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(height: 100),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(height: 100),
      ],
    );
  }

  void _openResult(
    BuildContext context,
    SearchProvider provider,
    SearchResultModel result,
  ) {
    provider.submitSearch(provider.query);
    ReadingNavigation.openSurah(
      context,
      surahNumber: result.surahNumber,
      initialAyah: result.numberInSurah,
    );
  }
}
