import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String habitsKey = 'habits_v1';
  static const String logsKey = 'habit_logs_v1';

  Future<void> saveStringList(String key, List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, values);
  }

  Future<List<String>> readStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? <String>[];
  }

  Future<void> saveMapList(String key, List<Map<String, dynamic>> list) async {
    final serialized = list.map((e) => jsonEncode(e)).toList();
    await saveStringList(key, serialized);
  }

  Future<List<Map<String, dynamic>>> readMapList(String key) async {
    final list = await readStringList(key);
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}
