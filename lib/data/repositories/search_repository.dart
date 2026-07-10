import '../datasources/local/hive_local_datasource.dart';
import '../datasources/remote/quran_remote_datasource.dart';
import '../models/search_result_model.dart';
import '../models/surah_model.dart';

/// Repository for verse and surah search.
class SearchRepository {
  SearchRepository({
    required HiveLocalDataSource local,
    required QuranRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final HiveLocalDataSource _local;
  final QuranRemoteDataSource _remote;

  static const _suggestions = [
    'mercy',
    'paradise',
    'patience',
    'guidance',
    'forgiveness',
    'prayer',
    'faith',
    'charity',
  ];

  Future<List<SearchResultModel>> searchLocal(String query) {
    return _local.searchLocal(query);
  }

  Future<List<SearchResultModel>> searchRemote(String query) {
    return _remote.searchAllLanguages(query);
  }

  /// Cache-first search: local results returned immediately by caller,
  /// remote merged separately.
  Future<List<SearchResultModel>> search(String query) async {
    final local = await searchLocal(query);
    try {
      final remote = await searchRemote(query);
      return _mergeResults(local, remote);
    } catch (_) {
      return local;
    }
  }

  List<SearchResultModel> _mergeResults(
    List<SearchResultModel> local,
    List<SearchResultModel> remote,
  ) {
    final merged = <String, SearchResultModel>{};

    for (final result in local) {
      merged['${result.surahNumber}:${result.numberInSurah}'] = result;
    }

    for (final result in remote) {
      final key = '${result.surahNumber}:${result.numberInSurah}';
      final existing = merged[key];
      if (existing != null) {
        merged[key] = SearchResultModel(
          surahNumber: result.surahNumber,
          numberInSurah: result.numberInSurah,
          globalAyahNumber: result.globalAyahNumber ?? existing.globalAyahNumber,
          previewText: result.previewText,
          arabicText: existing.arabicText,
          englishText: result.englishText ?? existing.englishText,
          surahEnglishName: result.surahEnglishName,
          surahArabicName: result.surahArabicName ?? existing.surahArabicName,
          matchedIn: existing.isLocal ? existing.matchedIn : result.matchedIn,
          isLocal: existing.isLocal,
        );
      } else {
        merged[key] = result;
      }
    }

    return merged.values.toList()
      ..sort((a, b) {
        final surahCmp = a.surahNumber.compareTo(b.surahNumber);
        if (surahCmp != 0) return surahCmp;
        return a.numberInSurah.compareTo(b.numberInSurah);
      });
  }

  Future<List<String>> recentSearches() => _local.getRecentSearches();

  Future<void> addRecentSearch(String query) => _local.addRecentSearch(query);

  Future<void> clearHistory() => _local.clearSearchHistory();

  Future<List<String>> getSuggestions(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      final recent = await recentSearches();
      if (recent.isNotEmpty) return recent.take(5).toList();
      return _suggestions.take(5).toList();
    }

    final suggestions = <String>{};

    final recent = await recentSearches();
    for (final item in recent) {
      if (item.toLowerCase().startsWith(q)) suggestions.add(item);
    }

    for (final item in _suggestions) {
      if (item.startsWith(q)) suggestions.add(item);
    }

    final surahs = await _local.getSurahs();
    for (final surah in surahs) {
      if (surah.englishName.toLowerCase().startsWith(q)) {
        suggestions.add(surah.englishName);
      }
    }

    return suggestions.take(8).toList();
  }

  Future<List<SurahModel>> getSurahs() => _local.getSurahs();
}
