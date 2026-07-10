/// Extended reading goal with multiple types and units.
class TrackingGoalModel {
  const TrackingGoalModel({
    required this.id,
    required this.type,
    required this.unit,
    required this.target,
    this.completed = 0,
    required this.createdAt,
    this.periodStart,
    this.title,
  });

  final String id;
  final String type;
  final String unit;
  final int target;
  final int completed;
  final String? title;
  final DateTime createdAt;
  final DateTime? periodStart;

  double get progressPercent =>
      target > 0 ? (completed / target).clamp(0.0, 1.0) : 0;

  int get remaining => (target - completed).clamp(0, target);

  bool get isComplete => completed >= target;

  TrackingGoalModel copyWith({int? completed, DateTime? periodStart}) {
    return TrackingGoalModel(
      id: id,
      type: type,
      unit: unit,
      target: target,
      completed: completed ?? this.completed,
      title: title,
      createdAt: createdAt,
      periodStart: periodStart ?? this.periodStart,
    );
  }

  factory TrackingGoalModel.fromMap(Map<dynamic, dynamic> map) {
    return TrackingGoalModel(
      id: map['id'] as String,
      type: map['type'] as String,
      unit: map['unit'] as String,
      target: map['target'] as int,
      completed: map['completed'] as int? ?? 0,
      title: map['title'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      periodStart: map['periodStart'] != null
          ? DateTime.parse(map['periodStart'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'unit': unit,
        'target': target,
        'completed': completed,
        if (title != null) 'title': title,
        'createdAt': createdAt.toIso8601String(),
        if (periodStart != null)
          'periodStart': periodStart!.toIso8601String(),
      };

  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    return '${type[0].toUpperCase()}${type.substring(1)} goal · $target $unit';
  }
}

/// Goal type and unit constants.
class GoalTypes {
  GoalTypes._();
  static const daily = 'daily';
  static const weekly = 'weekly';
  static const monthly = 'monthly';
  static const custom = 'custom';
}

class GoalUnits {
  GoalUnits._();
  static const ayahs = 'ayahs';
  static const pages = 'pages';
  static const minutes = 'minutes';
  static const juz = 'juz';
  static const surahs = 'surahs';
  static const quran = 'quran';
}
