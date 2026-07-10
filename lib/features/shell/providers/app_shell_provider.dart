import 'package:flutter/foundation.dart';

/// Controls bottom navigation tab index across the app shell.
class AppShellProvider extends ChangeNotifier {
  int _currentIndex = 0;
  String? _pendingSearchQuery;

  int get currentIndex => _currentIndex;
  String? get pendingSearchQuery => _pendingSearchQuery;

  void setIndex(int index, {String? searchQuery}) {
    _currentIndex = index;
    _pendingSearchQuery = searchQuery;
    notifyListeners();
  }

  String? consumeSearchQuery() {
    final query = _pendingSearchQuery;
    _pendingSearchQuery = null;
    return query;
  }
}
