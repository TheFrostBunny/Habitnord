import 'dart:convert';

class HabitLog {
  final String habitId;
  final DateTime date; // normalized to local date

  HabitLog({required this.habitId, required this.date});

  factory HabitLog.fromMap(Map<String, dynamic> map) => HabitLog(
    habitId: map['habitId'] as String,
    date: DateTime.parse(map['date'] as String),
  );

  Map<String, dynamic> toMap() => {
    'habitId': habitId,
    'date':
        DateTime(
          DateTime.parse(date.toIso8601String()).year,
          DateTime.parse(date.toIso8601String()).month,
          DateTime.parse(date.toIso8601String()).day,
        ).toIso8601String(),
  };

  String toJson() => jsonEncode(toMap());
  factory HabitLog.fromJson(String source) =>
      HabitLog.fromMap(jsonDecode(source));
}
