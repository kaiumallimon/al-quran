/// Local user profile stored offline-first.
class UserProfileModel {
  const UserProfileModel({
    this.uid,
    this.displayName = 'Guest Reader',
    this.email,
    this.photoUrl,
    this.authProvider = AuthProvider.local,
    this.joinDate,
    this.preferredLanguage = 'en',
  });

  final String? uid;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final AuthProvider authProvider;
  final DateTime? joinDate;
  final String preferredLanguage;

  bool get isSignedIn => uid != null && authProvider != AuthProvider.local;

  UserProfileModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    AuthProvider? authProvider,
    DateTime? joinDate,
    String? preferredLanguage,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      joinDate: joinDate ?? this.joinDate,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  factory UserProfileModel.fromMap(Map<dynamic, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] as String?,
      displayName: map['displayName'] as String? ?? 'Guest Reader',
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
      authProvider: AuthProvider.fromString(
        map['authProvider'] as String? ?? 'local',
      ),
      joinDate: map['joinDate'] != null
          ? DateTime.parse(map['joinDate'] as String)
          : null,
      preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toMap() => {
        if (uid != null) 'uid': uid,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'authProvider': authProvider.name,
        'joinDate': joinDate?.toIso8601String(),
        'preferredLanguage': preferredLanguage,
      };
}

enum AuthProvider {
  local,
  anonymous,
  google,
  apple;

  String get label {
    switch (this) {
      case AuthProvider.local:
        return 'Local';
      case AuthProvider.anonymous:
        return 'Anonymous';
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
    }
  }

  static AuthProvider fromString(String value) {
    return AuthProvider.values.firstWhere(
      (provider) => provider.name == value,
      orElse: () => AuthProvider.local,
    );
  }
}

/// Summary statistics shown on the profile screen.
class ProfileStatsModel {
  const ProfileStatsModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completedSurahs = 0,
    this.completedJuz = 0,
    this.activeGoals = 0,
    this.totalAyahsRead = 0,
    this.totalReadingMinutes = 0,
  });

  final int currentStreak;
  final int longestStreak;
  final int completedSurahs;
  final int completedJuz;
  final int activeGoals;
  final int totalAyahsRead;
  final int totalReadingMinutes;
}
