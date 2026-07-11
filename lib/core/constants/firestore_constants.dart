/// Cloud Firestore collection and document paths for user sync data.
class FirestoreConstants {
  FirestoreConstants._();

  static const String usersCollection = 'users';

  static const String profileDoc = 'profile';
  static const String settingsDoc = 'settings';
  static const String readingProgressDoc = 'reading_progress';
  static const String streakDoc = 'streak';
  static const String dailyGoalDoc = 'daily_goal';
  static const String syncMetaDoc = 'sync_meta';

  static const String bookmarksCollection = 'bookmarks';
  static const String favoritesCollection = 'favorites';
  static const String notesCollection = 'notes';
  static const String reflectionsCollection = 'reflections';
  static const String goalsCollection = 'goals';
  static const String sessionsCollection = 'sessions';
  static const String milestonesCollection = 'milestones';
  static const String scrollPositionsCollection = 'scroll_positions';
}
