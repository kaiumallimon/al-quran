import '../models/ayah_model.dart';
import '../models/bookmark_model.dart';
import '../models/favorite_model.dart';
import '../models/milestone_model.dart';
import '../models/note_model.dart';
import '../models/reflection_model.dart';
import '../models/reading_session_model.dart';
import '../models/tracking_goal_model.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../datasources/local/tracking_local_datasource.dart';

/// Repository for bookmarks, notes, reflections, goals, history, milestones.
class TrackingRepository {
  TrackingRepository({
    required TrackingLocalDataSource trackingLocal,
    required HiveLocalDataSource hiveLocal,
  })  : _tracking = trackingLocal,
        _hive = hiveLocal;

  final TrackingLocalDataSource _tracking;
  final HiveLocalDataSource _hive;

  // --- Bookmarks ---

  Future<List<BookmarkModel>> getBookmarks({String? folder, String? query}) async {
    var bookmarks = await _tracking.getBookmarks(folder: folder);
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      bookmarks = bookmarks
          .where((b) =>
              b.reference.contains(q) ||
              (b.surahEnglishName?.toLowerCase().contains(q) ?? false) ||
              (b.note?.toLowerCase().contains(q) ?? false) ||
              (b.ayahPreview?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return bookmarks;
  }

  Future<List<String>> getBookmarkFolders() => _tracking.getBookmarkFolders();

  Future<bool> isBookmarked(int surahNumber, int numberInSurah) =>
      _tracking.isBookmarked(surahNumber, numberInSurah);

  Future<bool> toggleBookmark({
    required AyahModel ayah,
    required String surahEnglishName,
    String? surahArabicName,
    String? note,
    String folder = 'General',
  }) async {
    final existing = await _tracking.findBookmark(
      ayah.surahNumber,
      ayah.numberInSurah,
    );

    if (existing != null) {
      await _tracking.deleteBookmark(existing.id);
      return false;
    }

    final now = DateTime.now();
    final bookmark = BookmarkModel(
      id: _tracking.generateId(),
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.number,
      numberInSurah: ayah.numberInSurah,
      surahEnglishName: surahEnglishName,
      surahArabicName: surahArabicName,
      ayahPreview: ayah.text,
      note: note,
      folder: folder,
      createdAt: now,
      updatedAt: now,
    );

    await _tracking.addBookmark(bookmark);
    await _checkFirstBookmarkMilestone();
    return true;
  }

  Future<void> deleteBookmark(String id) => _tracking.deleteBookmark(id);

  Future<void> updateBookmark(BookmarkModel bookmark) =>
      _tracking.updateBookmark(bookmark);

  // --- Favorites ---

  Future<List<FavoriteModel>> getFavorites() => _tracking.getFavorites();

  Future<bool> isFavorite(int surahNumber, int numberInSurah) =>
      _tracking.isFavorite(surahNumber, numberInSurah);

  Future<bool> toggleFavorite({
    required AyahModel ayah,
    required String surahEnglishName,
  }) async {
    final existing = await _tracking.findFavorite(
      ayah.surahNumber,
      ayah.numberInSurah,
    );

    if (existing != null) {
      await _tracking.removeFavorite(existing.id);
      return false;
    }

    await _tracking.addFavorite(FavoriteModel(
      id: _tracking.generateId(),
      surahNumber: ayah.surahNumber,
      numberInSurah: ayah.numberInSurah,
      surahEnglishName: surahEnglishName,
      ayahPreview: ayah.text,
      createdAt: DateTime.now(),
    ));
    return true;
  }

  // --- Notes ---

  Future<List<NoteModel>> getNotes({String? query}) =>
      _tracking.getNotes(query: query);

  Future<NoteModel> createNote({
    required AyahModel ayah,
    required String surahEnglishName,
    String content = '',
  }) async {
    final now = DateTime.now();
    final note = NoteModel(
      id: _tracking.generateId(),
      surahNumber: ayah.surahNumber,
      numberInSurah: ayah.numberInSurah,
      content: content,
      surahEnglishName: surahEnglishName,
      ayahPreview: ayah.text,
      createdAt: now,
      updatedAt: now,
    );
    await _tracking.saveNote(note);
    await _checkFirstNoteMilestone();
    return note;
  }

  Future<NoteModel> saveNote(NoteModel note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    return _tracking.saveNote(updated);
  }

  Future<void> deleteNote(String id) => _tracking.deleteNote(id);

  Future<void> toggleNotePin(NoteModel note) =>
      _tracking.saveNote(note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      ));

  Future<void> toggleNoteFavorite(NoteModel note) =>
      _tracking.saveNote(note.copyWith(
        isFavorite: !note.isFavorite,
        updatedAt: DateTime.now(),
      ));

  // --- Reflections ---

  Future<List<ReflectionModel>> getReflections({DateTime? date}) =>
      _tracking.getReflections(date: date);

  Future<ReflectionModel> createReflection({
    required AyahModel ayah,
    required String surahEnglishName,
    String content = '',
  }) async {
    final now = DateTime.now();
    final reflection = ReflectionModel(
      id: _tracking.generateId(),
      surahNumber: ayah.surahNumber,
      numberInSurah: ayah.numberInSurah,
      content: content,
      surahEnglishName: surahEnglishName,
      ayahPreview: ayah.text,
      createdAt: now,
      updatedAt: now,
    );
    await _tracking.saveReflection(reflection);
    await _checkFirstReflectionMilestone();
    return reflection;
  }

  Future<ReflectionModel> saveReflection(ReflectionModel reflection) async {
    final updated = reflection.copyWith(updatedAt: DateTime.now());
    return _tracking.saveReflection(updated);
  }

  Future<void> deleteReflection(String id) => _tracking.deleteReflection(id);

  Future<void> toggleReflectionFavorite(ReflectionModel reflection) =>
      _tracking.saveReflection(reflection.copyWith(
        isFavorite: !reflection.isFavorite,
        updatedAt: DateTime.now(),
      ));

  // --- Goals ---

  Future<List<TrackingGoalModel>> getGoals() => _tracking.getGoals();

  Future<TrackingGoalModel> createGoal({
    required String type,
    required String unit,
    required int target,
    String? title,
  }) async {
    final goal = TrackingGoalModel(
      id: _tracking.generateId(),
      type: type,
      unit: unit,
      target: target,
      title: title,
      createdAt: DateTime.now(),
      periodStart: DateTime.now(),
    );
    await _tracking.saveGoal(goal);
    return goal;
  }

  Future<void> updateGoal(TrackingGoalModel goal) => _tracking.saveGoal(goal);

  Future<void> deleteGoal(String id) => _tracking.deleteGoal(id);

  Future<void> recordReadingProgress({
    int ayahs = 0,
    int pages = 0,
    int minutes = 0,
  }) async {
    if (ayahs > 0) await _tracking.incrementGoalProgress(GoalUnits.ayahs, ayahs);
    if (pages > 0) await _tracking.incrementGoalProgress(GoalUnits.pages, pages);
    if (minutes > 0) {
      await _tracking.incrementGoalProgress(GoalUnits.minutes, minutes);
    }

    await _checkReadingMilestones(ayahs: ayahs);
  }

  // --- History ---

  Future<List<ReadingSessionModel>> getAllSessions() =>
      _tracking.getAllSessions();

  Future<List<ReadingSessionModel>> getSessionsForDate(DateTime date) =>
      _tracking.getSessionsForDate(date);

  Future<Map<DateTime, List<ReadingSessionModel>>> getSessionsByDate() =>
      _tracking.getSessionsByDate();

  Future<void> recordSession({
    int ayahsRead = 1,
    int pagesRead = 0,
    int durationMinutes = 0,
    int? surahNumber,
    bool wasOffline = true,
  }) async {
    final session = ReadingSessionModel(
      id: _tracking.generateId(),
      startedAt: DateTime.now(),
      durationMinutes: durationMinutes,
      pagesRead: pagesRead,
      ayahsRead: ayahsRead,
      surahNumber: surahNumber,
      wasOffline: wasOffline,
    );
    await _tracking.saveSession(session);
    await recordReadingProgress(
      ayahs: ayahsRead,
      pages: pagesRead,
      minutes: durationMinutes,
    );
  }

  // --- Milestones ---

  Future<List<MilestoneModel>> getMilestones() => _tracking.getMilestones();

  Future<void> checkStreakMilestones(int currentStreak) async {
    if (currentStreak >= 3) {
      await _award(MilestoneTypes.streak3, '3-Day Streak',
          'You read for 3 consecutive days.');
    }
    if (currentStreak >= 7) {
      await _award(MilestoneTypes.streak7, '7-Day Streak',
          'A full week of consistent reading.');
    }
    if (currentStreak >= 30) {
      await _award(MilestoneTypes.streak30, '30-Day Streak',
          'An entire month of dedication.');
    }
  }

  Future<void> _checkFirstBookmarkMilestone() async {
    await _award(MilestoneTypes.firstBookmark, 'First Bookmark',
        'You saved your first verse bookmark.');
  }

  Future<void> _checkFirstNoteMilestone() async {
    await _award(
        MilestoneTypes.firstNote, 'First Note', 'You wrote your first note.');
  }

  Future<void> _checkFirstReflectionMilestone() async {
    await _award(MilestoneTypes.firstReflection, 'First Reflection',
        'You recorded your first reflection.');
  }

  Future<void> _checkReadingMilestones({int ayahs = 0}) async {
    if (ayahs > 0) {
      await _award(MilestoneTypes.firstAyah, 'First Ayah Read',
          'Your journey with the Quran has begun.');
    }
  }

  Future<MilestoneModel?> _award(
    String type,
    String title,
    String description,
  ) async {
    return _tracking.awardMilestone(MilestoneModel(
      id: _tracking.generateId(),
      type: type,
      title: title,
      description: description,
      achievedAt: DateTime.now(),
    ));
  }

  Future<void> syncDailyGoalFromHive() async {
    final daily = await _hive.getDailyGoal();
    final goals = await getGoals();
    final hasDaily = goals.any((g) => g.type == GoalTypes.daily);

    if (!hasDaily && daily.targetAyahs > 0) {
      await createGoal(
        type: GoalTypes.daily,
        unit: GoalUnits.ayahs,
        target: daily.targetAyahs,
        title: 'Daily reading',
      );
    }
  }
}
