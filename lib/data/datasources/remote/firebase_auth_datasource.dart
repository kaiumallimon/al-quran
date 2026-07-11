import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../../models/user_profile_model.dart';

/// Remote authentication via Firebase Auth.
class FirebaseAuthDataSource {
  FirebaseAuthDataSource({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  Future<UserProfileModel> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return _profileFromUser(credential.user, AuthProvider.anonymous);
    } on FirebaseAuthException catch (error) {
      throw AuthenticationException(
        _messageForAuthError(error),
        code: error.code,
      );
    }
  }

  Future<UserProfileModel> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthenticationException(
          'Google sign-in did not return an ID token.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _signInOrLink(credential);
      return _profileFromUser(result.user, AuthProvider.google);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthenticationException('Google sign-in was cancelled.');
      }
      throw AuthenticationException(
        'Google sign-in failed. Please try again.',
        code: error.code.name,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthenticationException(
        _messageForAuthError(error),
        code: error.code,
      );
    }
  }

  Future<UserProfileModel> signInWithApple() async {
    if (kIsWeb || !(Platform.isIOS || Platform.isMacOS)) {
      throw const AuthenticationException(
        'Apple sign-in is only available on Apple devices.',
      );
    }

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null) {
        throw const AuthenticationException(
          'Apple sign-in did not return an identity token.',
        );
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        accessToken: appleCredential.authorizationCode,
      );

      final result = await _signInOrLink(oauthCredential);
      final profile = _profileFromUser(result.user, AuthProvider.apple);

      final fullName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].whereType<String>().where((part) => part.isNotEmpty).join(' ');

      if (fullName.isNotEmpty &&
          (profile.displayName.isEmpty ||
              profile.displayName == 'Guest Reader')) {
        return profile.copyWith(displayName: fullName);
      }

      return profile;
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const AuthenticationException('Apple sign-in was cancelled.');
      }
      throw AuthenticationException(
        'Apple sign-in failed. Please try again.',
        code: error.code.name,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthenticationException(
        _messageForAuthError(error),
        code: error.code,
      );
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      if (_googleInitialized) _googleSignIn.signOut(),
    ]);
  }

  UserProfileModel profileFromCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      return UserProfileModel(joinDate: DateTime.now());
    }
    return _profileFromUser(user, _providerForUser(user));
  }

  Future<UserCredential> _signInOrLink(AuthCredential credential) async {
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      return current.linkWithCredential(credential);
    }
    return _auth.signInWithCredential(credential);
  }

  UserProfileModel _profileFromUser(User? user, AuthProvider provider) {
    if (user == null) {
      throw const AuthenticationException('Authentication did not return a user.');
    }

    return UserProfileModel(
      uid: user.uid,
      displayName: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : _defaultName(provider),
      email: user.email,
      photoUrl: user.photoURL,
      authProvider: provider,
      joinDate: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  AuthProvider _providerForUser(User user) {
    for (final info in user.providerData) {
      switch (info.providerId) {
        case 'google.com':
          return AuthProvider.google;
        case 'apple.com':
          return AuthProvider.apple;
      }
    }
    if (user.isAnonymous) return AuthProvider.anonymous;
    return AuthProvider.local;
  }

  String _defaultName(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return 'Google User';
      case AuthProvider.apple:
        return 'Apple User';
      case AuthProvider.anonymous:
        return 'Guest Reader';
      case AuthProvider.local:
        return 'Guest Reader';
    }
  }

  String _messageForAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'network-request-failed':
        return 'Unable to connect. Check your internet connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'credential-already-in-use':
        return 'This account is already linked to another user.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }
}
