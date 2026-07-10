import 'package:flutter/foundation.dart';

import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/profile_repository.dart';

enum ProfileStatus { initial, loading, loaded, error }

/// View model for user profile and statistics.
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

  Future<void> signInAnonymously() async {
    _profile = await _repository.signInAnonymously();
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _profile = await _repository.signInWithGoogle();
    notifyListeners();
  }

  Future<void> signInWithApple() async {
    _profile = await _repository.signInWithApple();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _repository.signOut();
    await loadProfile();
  }
}
