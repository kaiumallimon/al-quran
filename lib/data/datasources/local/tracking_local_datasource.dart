import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/hive_constants.dart';
import '../../models/bookmark_model.dart';
import '../../models/favorite_model.dart';
import '../../models/milestone_model.dart';
import '../../models/note_model.dart';
import '../../models/reflection_model.dart';
import '../../models/reading_session_model.dart';
import '../../models/tracking_goal_model.dart';

/// Local Hive storage for personal tracking data.
class TrackingLocalDataSource {
  Future<void> init() async {
    await Future.wait([
      Hive.openBox(HiveConstants.bookmarksBox),
      Hive.openBox(HiveConstants.favoritesBox),
      Hive.openBox(HiveConstants.notesBox),
      Hive.openBox(HiveConstants.reflectionsBox),
      Hive.openBox(HiveConstants.milestonesBox),
    ]);
  }

  Box get _bookmarks => Hive.box(HiveConstants.bookmarksBox);
  Box get _favorites => Hive.box(HiveConstants.favoritesBox);
  Box get _notes => Hive.box(HiveConstants.notesBox);
  Box get _reflections => Hive.box(HiveConstants.reflectionsBox);
  Box get _milestones => Hive.box(HiveConstants.milestonesBox);
  Box get _goals => Hive.box(HiveConstants.goalsBox);
  Box get _sessions => Hive.box(HiveConstants.readingSessionsBox);

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // --- Bookmarks ---

  Future<List<BookmarkModel>> getBookmarks({String? folder}) async {
    final all = _bookmarks.values
        .map((e) => BookmarkModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();

    if (folder != null && folder != 'All') {
      return all.where((b) => b.folder == folder).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    return all..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<List<String>> getBookmarkFolders() async {
    final bookmarks = await getBookmarks();
    final folders = bookmarks.map((b) => b.folder).toSet().toList();
    folders.sort();
    return folders;
  }

  Future<bool> isBookmarked(int surahNumber, int numberInSurah) async {
    return _bookmarks.values.any((e) {
      final map = e as Map;
      return map['surahNumber'] == surahNumber &&
          map['numberInSurah'] == numberInSurah;
    });
  }

  Future<BookmarkModel> addBookmark(BookmarkModel bookmark) async {
    await _bookmarks.put(bookmark.id, bookmark.toMap());
    return bookmark;
  }

  Future<void> updateBookmark(BookmarkModel bookmark) async {
    await _bookmarks.put(bookmark.id, bookmark.toMap());
  }

  Future<void> deleteBookmark(String id) async {
    await _bookmarks.delete(id);
  }

  Future<BookmarkModel?> findBookmark(int surahNumber, int numberInSurah) async {
    for (final value in _bookmarks.values) {
      final map = value as Map;
      if (map['surahNumber'] == surahNumber &&
          map['numberInSurah'] == numberInSurah) {
        return BookmarkModel.fromMap(map);
      }
    }
    return null;
  }

  // --- Favorites ---

  Future<List<FavoriteModel>> getFavorites() async {
    return _favorites.values
        .map((e) => FavoriteModel.fromMap(e as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<bool> isFavorite(int surahNumber, int numberInSurah) async {
    return _favorites.values.any((e) {
      final map = e as Map;
      return map['surahNumber'] == surahNumber &&
          map['numberInSurah'] == numberInSurah;
    });
  }

  Future<FavoriteModel> addFavorite(FavoriteModel favorite) async {
    await _favorites.put(favorite.id, favorite.toMap());
    return favorite;
  }

  Future<void> removeFavorite(String id) async {
    await _favorites.delete(id);
  }

  Future<FavoriteModel?> findFavorite(int surahNumber, int numberInSurah) async {
    for (final value in _favorites.values) {
      final map = value as Map;
      if (map['surahNumber'] == surahNumber &&
          map['numberInSurah'] == numberInSurah) {
        return FavoriteModel.fromMap(map);
      }
    }
    return null;
  }

  // --- Notes ---

  Future<List<NoteModel>> getNotes({String? query}) async {
    var notes = _notes.values
        .map((e) => NoteModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      notes = notes
          .where((n) =>
              n.content.toLowerCase().contains(q) ||
              (n.surahEnglishName?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    notes.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  Future<NoteModel> saveNote(NoteModel note) async {
    await _notes.put(note.id, note.toMap());
    return note;
  }

  Future<void> deleteNote(String id) async {
    await _notes.delete(id);
  }

  Future<NoteModel?> getNote(String id) async {
    final map = _notes.get(id) as Map?;
    if (map == null) return null;
    return NoteModel.fromMap(map);
  }

  // --- Reflections ---

  Future<List<ReflectionModel>> getReflections({DateTime? date}) async {
    var items = _reflections.values
        .map((e) => ReflectionModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();

    if (date != null) {
      items = items.where((r) {
        return r.createdAt.year == date.year &&
            r.createdAt.month == date.month &&
            r.createdAt.day == date.day;
      }).toList();
    }

    return items..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<ReflectionModel> saveReflection(ReflectionModel reflection) async {
    await _reflections.put(reflection.id, reflection.toMap());
    return reflection;
  }

  Future<void> deleteReflection(String id) async {
    await _reflections.delete(id);
  }

  // --- Goals ---

  Future<List<TrackingGoalModel>> getGoals() async {
    return _goals.values
        .where((e) => (e as Map)['id'] != null)
        .map((e) => TrackingGoalModel.fromMap(e as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveGoal(TrackingGoalModel goal) async {
    await _goals.put(goal.id, goal.toMap());
  }

  Future<void> deleteGoal(String id) async {
    await _goals.delete(id);
  }

  Future<void> incrementGoalProgress(String unit, int amount) async {
    final goals = await getGoals();
    final now = DateTime.now();

    for (final goal in goals) {
      if (goal.unit != unit || goal.isComplete) continue;
      if (!_isGoalActive(goal, now)) continue;

      await saveGoal(goal.copyWith(completed: goal.completed + amount));
    }
  }

  bool _isGoalActive(TrackingGoalModel goal, DateTime now) {
    switch (goal.type) {
      case GoalTypes.daily:
        final start = goal.periodStart ?? goal.createdAt;
        return start.year == now.year &&
            start.month == now.month &&
            start.day == now.day;
      case GoalTypes.weekly:
        final start = goal.periodStart ?? goal.createdAt;
        return now.difference(start).inDays < 7;
      case GoalTypes.monthly:
        final start = goal.periodStart ?? goal.createdAt;
        return start.year == now.year && start.month == now.month;
      default:
        return true;
    }
  }

  // --- Milestones ---

  Future<List<MilestoneModel>> getMilestones() async {
    return _milestones.values
        .map((e) => MilestoneModel.fromMap(e as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
  }

  Future<bool> hasMilestone(String type) async {
    return _milestones.values.any((e) => (e as Map)['type'] == type);
  }

  Future<MilestoneModel?> awardMilestone(MilestoneModel milestone) async {
    if (await hasMilestone(milestone.type)) return null;
    await _milestones.put(milestone.id, milestone.toMap());
    return milestone;
  }

  // --- Reading History ---

  Future<List<ReadingSessionModel>> getAllSessions() async {
    return _sessions.values
        .map((e) => ReadingSessionModel.fromMap(e as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  Future<List<ReadingSessionModel>> getSessionsForDate(DateTime date) async {
    final all = await getAllSessions();
    return all.where((s) {
      return s.startedAt.year == date.year &&
          s.startedAt.month == date.month &&
          s.startedAt.day == date.day;
    }).toList();
  }

  Future<Map<DateTime, List<ReadingSessionModel>>> getSessionsByDate() async {
    final all = await getAllSessions();
    final grouped = <DateTime, List<ReadingSessionModel>>{};

    for (final session in all) {
      final key = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      grouped.putIfAbsent(key, () => []).add(session);
    }

    return grouped;
  }

  Future<void> saveSession(ReadingSessionModel session) async {
    await _sessions.put(session.id, session.toMap());
  }

  String generateId() => _newId();
}
