import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../services/storage_service.dart';

class HabitRepository extends ChangeNotifier {
  final StorageService _storage;
  HabitRepository(this._storage);

  final List<Habit> _habits = [];
  final List<HabitLog> _logs = [];

  List<Habit> get habits => List.unmodifiable(_habits);
  List<HabitLog> get logs => List.unmodifiable(_logs);

  Future<void> load() async {
    final habitMaps = await _storage.readMapList(StorageService.habitsKey);
    final logMaps = await _storage.readMapList(StorageService.logsKey);
    _habits
      ..clear()
      ..addAll(habitMaps.map(Habit.fromMap));
    _logs
      ..clear()
      ..addAll(logMaps.map(HabitLog.fromMap));
    notifyListeners();
  }

  Future<void> addHabit(
    String name,
    String colorHex, {
    String? description,
    String? iconName,
  }) async {
    final id = _generateId();
    _habits.add(
      Habit(
        id: id,
        name: name,
        colorHex: colorHex,
        description: description,
        iconName: iconName,
      ),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> updateHabit(
    Habit habit, {
    String? name,
    String? colorHex,
    String? description,
    String? iconName,
  }) async {
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx == -1) return;
    _habits[idx] = Habit(
      id: habit.id,
      name: name ?? habit.name,
      colorHex: colorHex ?? habit.colorHex,
      description: description ?? habit.description,
      iconName: iconName ?? habit.iconName,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> deleteHabit(Habit habit) async {
    _habits.removeWhere((h) => h.id == habit.id);
    _logs.removeWhere((l) => l.habitId == habit.id);
    await _persist();
    notifyListeners();
  }

  Future<void> toggleCompletion(Habit habit, DateTime date) async {
    final d = DateTime(date.year, date.month, date.day);
    final existingIdx = _logs.indexWhere(
      (l) => l.habitId == habit.id && _sameDay(l.date, d),
    );
    if (existingIdx >= 0) {
      _logs.removeAt(existingIdx);
    } else {
      _logs.add(HabitLog(habitId: habit.id, date: d));
    }
    await _persist();
    notifyListeners();
  }

  int countCompletionsInRange(DateTime start, DateTime end) {
    return _logs
        .where((l) => !l.date.isBefore(start) && !l.date.isAfter(end))
        .length;
  }

  Map<DateTime, int> completionsPerDay(DateTime start, DateTime end) {
    final Map<DateTime, int> map = {};
    for (var l in _logs) {
      if (l.date.isBefore(start) || l.date.isAfter(end)) continue;
      final key = DateTime(l.date.year, l.date.month, l.date.day);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  Future<void> _persist() async {
    await _storage.saveMapList(
      StorageService.habitsKey,
      _habits.map((e) => e.toMap()).toList(),
    );
    await _storage.saveMapList(
      StorageService.logsKey,
      _logs.map((e) => e.toMap()).toList(),
    );
  }

  String _generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
