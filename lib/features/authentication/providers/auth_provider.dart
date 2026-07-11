import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/sync_coordinator.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/auth_repository.dart';

enum AuthStatus {
  checking,
  unauthenticated,
  authenticated,
  signingIn,
}

/// View model for startup authentication and session state.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthRepository authRepository,
    required SyncCoordinator syncCoordinator,
  })  : _authRepository = authRepository,
        _syncCoordinator = syncCoordinator;

  final AuthRepository _authRepository;
  final SyncCoordinator _syncCoordinator;

  AuthStatus _status = AuthStatus.checking;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  void initialize() {
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (_status == AuthStatus.signingIn) return;

      _status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signInAnonymously() => _signIn(_authRepository.signInAnonymously);

  Future<void> signInWithGoogle() => _signIn(_authRepository.signInWithGoogle);

  Future<void> signInWithApple() => _signIn(_authRepository.signInWithApple);

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) =>
      _signIn(
        () => _authRepository.signInWithEmailPassword(
          email: email,
          password: password,
        ),
      );

  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _signIn(
        () => _authRepository.registerWithEmailPassword(
          email: email,
          password: password,
          displayName: displayName,
        ),
      );

  Future<void> _signIn(Future<UserProfileModel> Function() action) async {
    _status = AuthStatus.signingIn;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _status = AuthStatus.authenticated;
      _syncCoordinator.scheduleSync();
    } on AuthenticationException catch (error) {
      _errorMessage = error.message;
      _status = AuthStatus.unauthenticated;
    } catch (_) {
      _errorMessage = 'Sign-in failed. Please try again.';
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
