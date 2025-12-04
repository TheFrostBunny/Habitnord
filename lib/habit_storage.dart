import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class HabitStorage {
  late File habitsFile;

  Future<void> initFile() async {
    final dir = await getApplicationDocumentsDirectory();
    habitsFile = File('${dir.path}/habits.json');
  }

  Future<List<Map<String, dynamic>>> loadHabits() async {
    if (await habitsFile.exists()) {
      final contents = await habitsFile.readAsString();
      final decoded = jsonDecode(contents) as List;
      return decoded.map<Map<String, dynamic>>((h) {
        return {
          'color': Color(h['color'] as int),
          'icon': IconData(h['icon'] as int, fontFamily: 'MaterialIcons'),
          'title': h['title'],
          'subtitle': h['subtitle'],
          'checked': h['checked'],
          'heatmapColor': Color(h['heatmapColor'] as int),
        };
      }).toList();
    } else {
      return [];
    }
  }

  Future<void> saveHabits(List<Map<String, dynamic>> habits) async {
    final encoded = jsonEncode(habits.map((h) => {
      'color': h['color'] is Color ? (h['color'] as Color).toARGB32() : h['color'],
      'icon': (h['icon'] is IconData) ? (h['icon'] as IconData).codePoint : h['icon'],
      'title': h['title'],
      'subtitle': h['subtitle'],
      'checked': h['checked'],
      'heatmapColor': h['heatmapColor'] is Color ? (h['heatmapColor'] as Color).toARGB32() : h['heatmapColor'],
    }).toList());
    await habitsFile.writeAsString(encoded);
  }
}