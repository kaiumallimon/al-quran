import 'package:flutter/foundation.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/profile_repository.dart';

enum ProfileStatus { initial, loading, loaded, error, signingIn, syncing }

/// View model for user profile, statistics, and account actions.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;

  ProfileStatus _status = ProfileStatus.initial;
  UserProfileModel? _profile;
  ProfileStatsModel? _stats;
  String? _errorMessage;

  ProfileStatus get status => _status;
  UserProfileModel? get profile => _profile;
  ProfileStatsModel? get stats => _stats;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncedAt => _repository.lastSyncedAt;
  bool get isSyncing => _repository.isSyncing;

  Future<void> loadProfile() async {
    if (_status == ProfileStatus.loading) return;

    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
      _stats = await _repository.getStats();
      _status = ProfileStatus.loaded;
    } catch (_) {
      _errorMessage = 'Unable to load profile.';
      _status = ProfileStatus.error;
    }

    notifyListeners();
  }

  Future<void> updateDisplayName(String name) async {
    if (_profile == null || name.trim().isEmpty) return;
    _profile = _profile!.copyWith(displayName: name.trim());
    await _repository.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> signInAnonymously() => _signIn(_repository.signInAnonymously);

  Future<void> signInWithGoogle() => _signIn(_repository.signInWithGoogle);

  Future<void> signInWithApple() => _signIn(_repository.signInWithApple);

  Future<void> signOut() async {
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      _profile = await _repository.signOut();
      _stats = await _repository.getStats();
      _errorMessage = null;
      _status = ProfileStatus.loaded;
    } catch (_) {
      _errorMessage = 'Unable to sign out.';
      _status = ProfileStatus.error;
    }

    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_profile == null || !_profile!.isSignedIn) return;

    _status = ProfileStatus.syncing;
    notifyListeners();

    try {
      await _repository.syncNow();
      _profile = await _repository.getProfile();
      _stats = await _repository.getStats();
      _errorMessage = null;
      _status = ProfileStatus.loaded;
    } on SyncException catch (error) {
      _errorMessage = error.message;
      _status = ProfileStatus.loaded;
    } catch (_) {
      _errorMessage = 'Cloud sync failed. Your local data is still safe.';
      _status = ProfileStatus.loaded;
    }

    notifyListeners();
  }

  Future<void> _signIn(Future<UserProfileModel> Function() action) async {
    _status = ProfileStatus.signingIn;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await action();
      _stats = await _repository.getStats();
      _status = ProfileStatus.loaded;
    } on AuthenticationException catch (error) {
      _errorMessage = error.message;
      _status = ProfileStatus.loaded;
    } catch (_) {
      _errorMessage = 'Sign-in failed. Please try again.';
      _status = ProfileStatus.loaded;
    }

    notifyListeners();
  }
}
