import 'package:firebase_auth/firebase_auth.dart';

import '../../core/exceptions/app_exceptions.dart';
import '../datasources/local/profile_local_datasource.dart';
import '../datasources/remote/firebase_auth_datasource.dart';
import '../models/user_profile_model.dart';

/// Authentication repository backed by Firebase Auth with local profile cache.
class AuthRepository {
  AuthRepository({
    required FirebaseAuthDataSource remote,
    required ProfileLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final FirebaseAuthDataSource _remote;
  final ProfileLocalDataSource _local;

  Stream<User?> get authStateChanges => _remote.authStateChanges;

  String? get currentUid => _remote.currentUser?.uid;

  bool get isSignedIn => _remote.currentUser != null;

  Future<UserProfileModel> signInAnonymously() async {
    final profile = await _remote.signInAnonymously();
    await _local.saveProfile(profile);
    return profile;
  }

  Future<UserProfileModel> signInWithGoogle() async {
    final profile = await _remote.signInWithGoogle();
    await _local.saveProfile(profile);
    return profile;
  }

  Future<UserProfileModel> signInWithApple() async {
    final profile = await _remote.signInWithApple();
    await _local.saveProfile(profile);
    return profile;
  }

  Future<UserProfileModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final profile = await _remote.signInWithEmailPassword(
      email: email,
      password: password,
    );
    await _local.saveProfile(profile);
    return profile;
  }

  Future<UserProfileModel> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final profile = await _remote.registerWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    await _local.saveProfile(profile);
    return profile;
  }

  Future<UserProfileModel> signOut() async {
    await _remote.signOut();
    final localProfile = UserProfileModel(joinDate: DateTime.now());
    await _local.saveProfile(localProfile);
    return localProfile;
  }

  Future<UserProfileModel> refreshProfileFromAuth() async {
    if (!isSignedIn) {
      return _local.getProfile();
    }

    final profile = _remote.profileFromCurrentUser();
    await _local.saveProfile(profile);
    return profile;
  }

  Future<UserProfileModel> getCachedProfile() => _local.getProfile();

  Future<void> saveProfile(UserProfileModel profile) =>
      _local.saveProfile(profile);

  AuthenticationException mapError(Object error) {
    if (error is AuthenticationException) return error;
    return const AuthenticationException('Sign-in failed. Please try again.');
  }
}
