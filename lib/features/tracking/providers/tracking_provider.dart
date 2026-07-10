import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/ayah_model.dart';
import '../../../data/models/bookmark_model.dart';
import '../../../data/models/favorite_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/reflection_model.dart';
import '../../../data/models/reading_session_model.dart';
import '../../../data/models/tracking_goal_model.dart';
import '../../../data/repositories/tracking_repository.dart';

enum TrackingStatus { initial, loading, loaded, error }

/// View model for personal tracking features.
class TrackingProvider extends ChangeNotifier {
  TrackingProvider({required TrackingRepository repository})
      : _repository = repository;

  final TrackingRepository _repository;

  TrackingStatus _status = TrackingStatus.initial;
  String? _errorMessage;

  List<BookmarkModel> _bookmarks = [];
  List<FavoriteModel> _favorites = [];
  List<NoteModel> _notes = [];
  List<ReflectionModel> _reflections = [];
  List<TrackingGoalModel> _goals = [];
  List<ReadingSessionModel> _sessions = [];
  List<MilestoneModel> _milestones = [];
  List<String> _bookmarkFolders = [];

  String _bookmarkQuery = '';
  String _bookmarkFolder = 'All';
  String _noteQuery = '';
  DateTime? _reflectionDateFilter;

  Timer? _noteSaveTimer;
  NoteModel? _editingNote;
  ReflectionModel? _editingReflection;

  TrackingStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<BookmarkModel> get bookmarks => _bookmarks;
  List<FavoriteModel> get favorites => _favorites;
  List<NoteModel> get notes => _notes;
  List<ReflectionModel> get reflections => _reflections;
  List<TrackingGoalModel> get goals => _goals;
  List<ReadingSessionModel> get sessions => _sessions;
  List<MilestoneModel> get milestones => _milestones;
  List<String> get bookmarkFolders => _bookmarkFolders;
  String get bookmarkQuery => _bookmarkQuery;
  String get bookmarkFolder => _bookmarkFolder;
  String get noteQuery => _noteQuery;
  NoteModel? get editingNote => _editingNote;
  ReflectionModel? get editingReflection => _editingReflection;

  Future<void> loadAll() async {
    _status = TrackingStatus.loading;
    notifyListeners();

    try {
      await _repository.syncDailyGoalFromHive();
      await Future.wait([
        _loadBookmarks(),
        _loadFavorites(),
        _loadNotes(),
        _loadReflections(),
        _loadGoals(),
        _loadSessions(),
        _loadMilestones(),
      ]);
      _status = TrackingStatus.loaded;
    } catch (_) {
      _errorMessage = 'Unable to load tracking data.';
      _status = TrackingStatus.error;
    }

    notifyListeners();
  }

  Future<void> _loadBookmarks() async {
    _bookmarkFolders = await _repository.getBookmarkFolders();
    _bookmarks = await _repository.getBookmarks(
      folder: _bookmarkFolder == 'All' ? null : _bookmarkFolder,
      query: _bookmarkQuery.isEmpty ? null : _bookmarkQuery,
    );
  }

  Future<void> _loadFavorites() async {
    _favorites = await _repository.getFavorites();
  }

  Future<void> _loadNotes() async {
    _notes = await _repository.getNotes(
      query: _noteQuery.isEmpty ? null : _noteQuery,
    );
  }

  Future<void> _loadReflections() async {
    _reflections =
        await _repository.getReflections(date: _reflectionDateFilter);
  }

  Future<void> _loadGoals() async {
    _goals = await _repository.getGoals();
  }

  Future<void> _loadSessions() async {
    _sessions = await _repository.getAllSessions();
  }

  Future<void> _loadMilestones() async {
    _milestones = await _repository.getMilestones();
  }

  Future<bool> toggleBookmark({
    required int surahNumber,
    required int numberInSurah,
    required int ayahNumber,
    required String surahEnglishName,
    String? ayahPreview,
    String? surahArabicName,
  }) async {
    final added = await _repository.toggleBookmark(
      ayah: _ayahStub(
        surahNumber: surahNumber,
        numberInSurah: numberInSurah,
        ayahNumber: ayahNumber,
        text: ayahPreview ?? '',
      ),
      surahEnglishName: surahEnglishName,
      surahArabicName: surahArabicName,
    );
    await _loadBookmarks();
    await _loadMilestones();
    notifyListeners();
    return added;
  }

  Future<bool> isBookmarked(int surahNumber, int numberInSurah) =>
      _repository.isBookmarked(surahNumber, numberInSurah);

  Future<bool> toggleFavorite({
    required int surahNumber,
    required int numberInSurah,
    required String surahEnglishName,
    String? ayahPreview,
  }) async {
    final added = await _repository.toggleFavorite(
      ayah: _ayahStub(
        surahNumber: surahNumber,
        numberInSurah: numberInSurah,
        text: ayahPreview ?? '',
      ),
      surahEnglishName: surahEnglishName,
    );
    await _loadFavorites();
    notifyListeners();
    return added;
  }

  Future<bool> isFavorite(int surahNumber, int numberInSurah) =>
      _repository.isFavorite(surahNumber, numberInSurah);

  Future<void> deleteBookmark(String id) async {
    await _repository.deleteBookmark(id);
    await _loadBookmarks();
    notifyListeners();
  }

  void setBookmarkQuery(String query) async {
    _bookmarkQuery = query;
    await _loadBookmarks();
    notifyListeners();
  }

  void setBookmarkFolder(String folder) async {
    _bookmarkFolder = folder;
    await _loadBookmarks();
    notifyListeners();
  }

  void setNoteQuery(String query) async {
    _noteQuery = query;
    await _loadNotes();
    notifyListeners();
  }

  Future<NoteModel> startNote({
    required int surahNumber,
    required int numberInSurah,
    required String surahEnglishName,
    String? ayahPreview,
  }) async {
    final note = await _repository.createNote(
      ayah: _ayahStub(
        surahNumber: surahNumber,
        numberInSurah: numberInSurah,
        text: ayahPreview ?? '',
      ),
      surahEnglishName: surahEnglishName,
    );
    _editingNote = note;
    await _loadNotes();
    await _loadMilestones();
    notifyListeners();
    return note;
  }

  void scheduleNoteSave(NoteModel note, String content) {
    _noteSaveTimer?.cancel();
    _noteSaveTimer = Timer(const Duration(milliseconds: 500), () async {
      await _repository.saveNote(note.copyWith(content: content));
      await _loadNotes();
      notifyListeners();
    });
  }

  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    if (_editingNote?.id == id) _editingNote = null;
    await _loadNotes();
    notifyListeners();
  }

  Future<void> toggleNotePin(NoteModel note) async {
    await _repository.toggleNotePin(note);
    await _loadNotes();
    notifyListeners();
  }

  Future<ReflectionModel> startReflection({
    required int surahNumber,
    required int numberInSurah,
    required String surahEnglishName,
    String? ayahPreview,
  }) async {
    final reflection = await _repository.createReflection(
      ayah: _ayahStub(
        surahNumber: surahNumber,
        numberInSurah: numberInSurah,
        text: ayahPreview ?? '',
      ),
      surahEnglishName: surahEnglishName,
    );
    _editingReflection = reflection;
    await _loadReflections();
    await _loadMilestones();
    notifyListeners();
    return reflection;
  }

  void scheduleReflectionSave(ReflectionModel reflection, String content) {
    _noteSaveTimer?.cancel();
    _noteSaveTimer = Timer(const Duration(milliseconds: 500), () async {
      await _repository.saveReflection(reflection.copyWith(content: content));
      await _loadReflections();
      notifyListeners();
    });
  }

  Future<void> deleteReflection(String id) async {
    await _repository.deleteReflection(id);
    if (_editingReflection?.id == id) _editingReflection = null;
    await _loadReflections();
    notifyListeners();
  }

  Future<TrackingGoalModel> createGoal({
    required String type,
    required String unit,
    required int target,
    String? title,
  }) async {
    final goal = await _repository.createGoal(
      type: type,
      unit: unit,
      target: target,
      title: title,
    );
    await _loadGoals();
    notifyListeners();
    return goal;
  }

  Future<void> deleteGoal(String id) async {
    await _repository.deleteGoal(id);
    await _loadGoals();
    notifyListeners();
  }

  Future<Map<DateTime, List<ReadingSessionModel>>> getSessionsByDate() =>
      _repository.getSessionsByDate();

  Future<void> recordReadingActivity({
    required int surahNumber,
    required int ayahsRead,
    int pagesRead = 0,
  }) async {
    await _repository.recordReadingProgress(
      ayahs: ayahsRead,
      pages: pagesRead,
    );
    await _loadGoals();
    await _loadMilestones();
    notifyListeners();
  }

  Future<void> recordSession({
    required int surahNumber,
    int ayahsRead = 0,
    int pagesRead = 0,
    int durationMinutes = 0,
  }) async {
    await _repository.recordSession(
      surahNumber: surahNumber,
      ayahsRead: ayahsRead,
      pagesRead: pagesRead,
      durationMinutes: durationMinutes,
    );
    await _loadSessions();
    await _loadGoals();
    notifyListeners();
  }

  AyahModel _ayahStub({
    required int surahNumber,
    required int numberInSurah,
    required String text,
    int ayahNumber = 0,
  }) {
    return AyahModel(
      number: ayahNumber,
      text: text,
      numberInSurah: numberInSurah,
      surahNumber: surahNumber,
    );
  }

  @override
  void dispose() {
    _noteSaveTimer?.cancel();
    super.dispose();
  }
}
