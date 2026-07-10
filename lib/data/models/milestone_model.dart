/// A locally calculated achievement milestone.
class MilestoneModel {
  const MilestoneModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.achievedAt,
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime achievedAt;

  factory MilestoneModel.fromMap(Map<dynamic, dynamic> map) {
    return MilestoneModel(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      achievedAt: DateTime.parse(map['achievedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'title': title,
        'description': description,
        'achievedAt': achievedAt.toIso8601String(),
      };
}

/// Known milestone type identifiers.
class MilestoneTypes {
  MilestoneTypes._();

  static const firstAyah = 'first_ayah';
  static const firstSurah = 'first_surah';
  static const streak3 = 'streak_3';
  static const streak7 = 'streak_7';
  static const streak30 = 'streak_30';
  static const firstBookmark = 'first_bookmark';
  static const firstNote = 'first_note';
  static const firstReflection = 'first_reflection';
}
