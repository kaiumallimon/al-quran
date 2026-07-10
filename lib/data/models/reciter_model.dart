/// A Quran reciter available from alquran.cloud audio editions.
class ReciterModel {
  const ReciterModel({
    required this.id,
    required this.name,
    required this.language,
  });

  final String id;
  final String name;
  final String language;

  static const List<ReciterModel> defaults = [
    ReciterModel(
      id: 'ar.alafasy',
      name: 'Mishary Alafasy',
      language: 'ar',
    ),
    ReciterModel(
      id: 'ar.abdurrahmaansudais',
      name: 'Abdur-Rahman As-Sudais',
      language: 'ar',
    ),
    ReciterModel(
      id: 'ar.abdulbasitmurattal',
      name: 'Abdul Basit Murattal',
      language: 'ar',
    ),
    ReciterModel(
      id: 'ar.husary',
      name: 'Mahmoud Khalil Al-Husary',
      language: 'ar',
    ),
    ReciterModel(
      id: 'ar.minshawi',
      name: 'Mohamed Siddiq Al-Minshawi',
      language: 'ar',
    ),
    ReciterModel(
      id: 'ar.shaatree',
      name: 'Abu Bakr Ash-Shaatree',
      language: 'ar',
    ),
  ];

  static ReciterModel? findById(String id) {
    for (final reciter in defaults) {
      if (reciter.id == id) return reciter;
    }
    return null;
  }

  factory ReciterModel.fromMap(Map<dynamic, dynamic> map) {
    return ReciterModel(
      id: map['id'] as String,
      name: map['name'] as String,
      language: map['language'] as String? ?? 'ar',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'language': language,
      };
}
