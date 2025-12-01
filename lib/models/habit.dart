import 'dart:convert';

class Habit {
  final String id;
  String name;
  String colorHex; // For branding palette
  String? description;
  String? iconName; // Optional material icon name

  Habit({
    required this.id,
    required this.name,
    required this.colorHex,
    this.description,
    this.iconName,
  });

  factory Habit.fromMap(Map<String, dynamic> map) => Habit(
    id: map['id'] as String,
    name: map['name'] as String,
    colorHex: map['colorHex'] as String,
    description: map['description'] as String?,
    iconName: map['iconName'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'colorHex': colorHex,
    'description': description,
    'iconName': iconName,
  };

  String toJson() => jsonEncode(toMap());
  factory Habit.fromJson(String source) => Habit.fromMap(jsonDecode(source));
}
