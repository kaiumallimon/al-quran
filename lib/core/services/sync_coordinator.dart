import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/datasources/local/profile_local_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/sync_repository.dart';

/// Triggers background cloud sync without blocking the UI.
class SyncCoordinator {
  SyncCoordinator({
    required AuthRepository authRepository,
    required SyncRepository syncRepository,
    required ProfileLocalDataSource profileLocal,
    Connectivity? connectivity,
  })  : _authRepository = authRepository,
        _syncRepository = syncRepository,
        _profileLocal = profileLocal,
        _connectivity = connectivity ?? Connectivity();

  final AuthRepository _authRepository;
  final SyncRepository _syncRepository;
  final ProfileLocalDataSource _profileLocal;
  final Connectivity _connectivity;

  StreamSubscription<dynamic>? _authSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void start() {
    _authSubscription =
        _authRepository.authStateChanges.listen((_) => scheduleSync());
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        if (results.any((result) => result != ConnectivityResult.none)) {
          scheduleSync();
        }
      },
    );
  }

  void scheduleSync() {
    unawaited(syncIfEligible());
  }

  Future<void> syncIfEligible() async {
    if (!_authRepository.isSignedIn) return;

    final settings = await _profileLocal.getSettings();
    if (!settings.syncEnabled) return;

    final uid = _authRepository.currentUid;
    if (uid == null || _syncRepository.isSyncing) return;

    try {
      await _syncRepository.syncAll(uid: uid, syncEnabled: true);
    } catch (_) {
      // Sync failures are stored on the repository; never block the UI.
    }
  }

  void dispose() {
    _authSubscription?.cancel();
    _connectivitySubscription?.cancel();
  }
}
