import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

const usedIcons = [
  Icons.star,
  Icons.self_improvement,
  Icons.code,
  Icons.music_note,
  Icons.directions_run,
  Icons.coffee,
  Icons.book,
  Icons.fitness_center,
  Icons.fastfood,
  Icons.nightlight_round,
  Icons.water_drop,
  Icons.sunny,
  Icons.check_circle,
  Icons.timer,
  Icons.directions_bike,
  Icons.spa,
];

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
          'icon': usedIcons[h['iconIndex'] as int],
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
    final encoded = jsonEncode(
      habits
          .map(
            (h) => {
              'color':
                  h['color'] is Color
                      ? ((h['color'] as Color).a.toInt() << 24) |
                          ((h['color'] as Color).r.toInt() << 16) |
                          ((h['color'] as Color).g.toInt() << 8) |
                          (h['color'] as Color).b.toInt()
                      : h['color'],
              'iconIndex': usedIcons.indexOf(h['icon']),
              'title': h['title'],
              'subtitle': h['subtitle'],
              'checked': h['checked'],
              'heatmapColor':
                  h['heatmapColor'] is Color
                      ? ((h['heatmapColor'] as Color).a.toInt() << 24) |
                          ((h['heatmapColor'] as Color).r.toInt() << 16) |
                          ((h['heatmapColor'] as Color).g.toInt() << 8) |
                          (h['heatmapColor'] as Color).b.toInt()
                      : h['heatmapColor'],
            },
          )
          .toList(),
    );
    await habitsFile.writeAsString(encoded);
  }
}
