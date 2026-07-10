/// Action types for recommendation tap handling.
enum RecommendationAction {
  continueReading,
  completeGoal,
  maintainStreak,
  openSurah,
  openGoals,
  openInsights,
}

/// A gentle, optional reading suggestion based on user habits.
class RecommendationModel {
  const RecommendationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.action,
    this.priority = 0,
    this.surahNumber,
    this.ayahNumber,
  });

  final String id;
  final String title;
  final String description;
  final RecommendationAction action;
  final int priority;
  final int? surahNumber;
  final int? ayahNumber;

  factory RecommendationModel.fromMap(Map<dynamic, dynamic> map) {
    return RecommendationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      action: RecommendationAction.values.firstWhere(
        (a) => a.name == map['action'],
        orElse: () => RecommendationAction.continueReading,
      ),
      priority: map['priority'] as int? ?? 0,
      surahNumber: map['surahNumber'] as int?,
      ayahNumber: map['ayahNumber'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'action': action.name,
        'priority': priority,
        if (surahNumber != null) 'surahNumber': surahNumber,
        if (ayahNumber != null) 'ayahNumber': ayahNumber,
      };
}
