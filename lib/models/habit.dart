import 'dart:convert';

class Habit {
  final String id;
  String name;
  String colorHex; // For branding palette

  Habit({required this.id, required this.name, required this.colorHex});

  factory Habit.fromMap(Map<String, dynamic> map) => Habit(
    id: map['id'] as String,
    name: map['name'] as String,
    colorHex: map['colorHex'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'colorHex': colorHex,
  };

  String toJson() => jsonEncode(toMap());
  factory Habit.fromJson(String source) => Habit.fromMap(jsonDecode(source));
}
