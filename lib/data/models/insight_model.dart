/// Category for grouping insights by time horizon.
enum InsightCategory {
  daily,
  weekly,
  monthly,
  lifetime,
}

/// A reading habit insight generated from local statistics.
class InsightModel {
  const InsightModel({
    required this.id,
    required this.message,
    required this.category,
    this.icon = 'insights',
    this.createdAt,
  });

  final String id;
  final String message;
  final InsightCategory category;
  final String icon;
  final DateTime? createdAt;

  factory InsightModel.fromMap(Map<dynamic, dynamic> map) {
    return InsightModel(
      id: map['id'] as String,
      message: map['message'] as String,
      category: InsightCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => InsightCategory.daily,
      ),
      icon: map['icon'] as String? ?? 'insights',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'message': message,
        'category': category.name,
        'icon': icon,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}
