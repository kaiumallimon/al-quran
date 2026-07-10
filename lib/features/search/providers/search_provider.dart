import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/search_result_model.dart';
import '../../../data/repositories/search_repository.dart';

enum SearchStatus { idle, searching, loaded, error }

/// View model for the search feature.
class SearchProvider extends ChangeNotifier {
  SearchProvider({required SearchRepository searchRepository})
      : _repository = searchRepository;

  final SearchRepository _repository;

  static const _debounceMs = 300;

  SearchStatus _status = SearchStatus.idle;
  String _query = '';
  List<SearchResultModel> _results = [];
  List<SearchResultModel> _localResults = [];
  List<String> _recentSearches = [];
  List<String> _suggestions = [];
  String? _errorMessage;
  bool _isRemoteLoading = false;
  Timer? _debounceTimer;

  SearchStatus get status => _status;
  String get query => _query;
  List<SearchResultModel> get results => _results;
  List<SearchResultModel> get localResults => _localResults;
  List<String> get recentSearches => _recentSearches;
  List<String> get suggestions => _suggestions;
  String? get errorMessage => _errorMessage;
  bool get isRemoteLoading => _isRemoteLoading;
  bool get hasQuery => _query.trim().length >= 2;

  Future<void> initialize() async {
    _recentSearches = await _repository.recentSearches();
    _suggestions = await _repository.getSuggestions('');
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    _debounceTimer?.cancel();

    if (value.trim().length < 2) {
      _results = [];
      _localResults = [];
      _status = SearchStatus.idle;
      _errorMessage = null;
      _isRemoteLoading = false;
      _loadSuggestions(value);
      notifyListeners();
      return;
    }

    _status = SearchStatus.searching;
    notifyListeners();

    _debounceTimer = Timer(
      const Duration(milliseconds: _debounceMs),
      () => _performSearch(value.trim()),
    );

    _loadSuggestions(value);
  }

  Future<void> _loadSuggestions(String value) async {
    _suggestions = await _repository.getSuggestions(value);
    notifyListeners();
  }

  Future<void> _performSearch(String trimmedQuery) async {
    _status = SearchStatus.searching;
    _errorMessage = null;
    notifyListeners();

    try {
      _localResults = await _repository.searchLocal(trimmedQuery);
      _results = List.from(_localResults);
      _status = SearchStatus.loaded;
      notifyListeners();

      _isRemoteLoading = true;
      notifyListeners();

      final merged = await _repository.search(trimmedQuery);
      if (_query.trim() == trimmedQuery) {
        _results = merged;
        _isRemoteLoading = false;
        notifyListeners();
      }
    } catch (_) {
      if (_localResults.isNotEmpty) {
        _results = _localResults;
        _status = SearchStatus.loaded;
      } else {
        _errorMessage = 'Search failed. Check your connection and try again.';
        _status = SearchStatus.error;
      }
      _isRemoteLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitSearch(String value) async {
    _query = value;
    _debounceTimer?.cancel();
    await _performSearch(value.trim());
    if (value.trim().length >= 2) {
      await _repository.addRecentSearch(value.trim());
      _recentSearches = await _repository.recentSearches();
      notifyListeners();
    }
  }

  Future<void> selectSuggestion(String suggestion) async {
    await submitSearch(suggestion);
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    _recentSearches = [];
    _suggestions = await _repository.getSuggestions(_query);
    notifyListeners();
  }

  Future<void> removeRecentSearch(String item) async {
    _recentSearches = _recentSearches.where((s) => s != item).toList();
    await _repository.clearHistory();
    for (final search in _recentSearches.reversed) {
      await _repository.addRecentSearch(search);
    }
    notifyListeners();
  }

  void clearQuery() {
    _debounceTimer?.cancel();
    _query = '';
    _results = [];
    _localResults = [];
    _status = SearchStatus.idle;
    _errorMessage = null;
    _isRemoteLoading = false;
    _loadSuggestions('');
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
