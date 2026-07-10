/// Represents a Quran edition from the API.
class EditionModel {
  const EditionModel({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    this.direction,
  });

  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;
  final String? direction;

  factory EditionModel.fromJson(Map<String, dynamic> json) {
    return EditionModel(
      identifier: json['identifier'] as String,
      language: json['language'] as String,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      format: json['format'] as String,
      type: json['type'] as String,
      direction: json['direction'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'language': language,
        'name': name,
        'englishName': englishName,
        'format': format,
        'type': type,
        if (direction != null) 'direction': direction,
      };

  factory EditionModel.fromMap(Map<dynamic, dynamic> map) {
    return EditionModel(
      identifier: map['identifier'] as String,
      language: map['language'] as String,
      name: map['name'] as String,
      englishName: map['englishName'] as String,
      format: map['format'] as String,
      type: map['type'] as String,
      direction: map['direction'] as String?,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditionModel && identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;
}
