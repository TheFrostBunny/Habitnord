import 'package:flutter/material.dart';
import 'habit_card.dart';
import 'habit_storage.dart';
import 'app_bar.dart';
import 'pages/settings_page.dart';
import 'hooks/translations.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_habit_dialog.dart';
import 'icon_picker.dart';

/// Hvis du allerede har denne liste et andet sted,
/// kan du slette denne og bruge din egen.
// Removed local usedIcons to use only the one from habit_storage.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> habits = [];
  Map<int, List<DateTime>> habitDates = {};
  final HabitStorage habitStorage = HabitStorage();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await habitStorage.initFile();

    final storedHabits = await habitStorage.loadHabits();
    final datesJson = prefs.getString('habitDates');

    debugPrint('Loaded habits: $storedHabits');

    if (storedHabits.isEmpty) {
      storedHabits.add({
        'color': Colors.blue,
        'icon': Icons.star,
        'iconIndex': 0,
        'title': 'Testvane',
        'subtitle': 'Dette er en test',
        'checked': false,
        'heatmapColor': Colors.blue,
      });
    }

    if (datesJson != null) {
      final decoded = jsonDecode(datesJson) as Map<String, dynamic>;
      habitDates = decoded.map(
        (key, value) => MapEntry(
          int.parse(key),
          (value as List).map((s) => DateTime.parse(s)).toList(),
        ),
      );
    }

    setState(() {
      habits = storedHabits;
      isLoading = false;
    });
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await habitStorage.initFile();

    await habitStorage.saveHabits(habits);

    final encoded = habitDates.map(
      (key, value) => MapEntry(
        key.toString(),
        value.map((d) => d.toIso8601String()).toList(),
      ),
    );

    prefs.setString('habitDates', jsonEncode(encoded));
  }

  void _toggleHabitChecked(int index) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    setState(() {
      final habit = habits[index];
      habit['checked'] = !(habit['checked'] as bool);

      habitDates.putIfAbsent(index, () => []);

      if (habit['checked']) {
        final exists = habitDates[index]!.any(
          (d) =>
              d.year == todayDate.year &&
              d.month == todayDate.month &&
              d.day == todayDate.day,
        );
        if (!exists) habitDates[index]!.add(todayDate);
      } else {
        habitDates[index]!.removeWhere(
          (d) =>
              d.year == todayDate.year &&
              d.month == todayDate.month &&
              d.day == todayDate.day,
        );
      }
    });

    _saveHabits();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'HabitNord',
        leadingIcon: Icons.settings,
        onLeadingTap: () async {
          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondary) => const SettingsPage(),
              transitionsBuilder: (context, animation, secondary, child) {
                final tween = Tween(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.ease));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => const AddHabitDialog(),
          );
          if (result != null) {
            setState(() {
              habits.add(result);
            });
            await _saveHabits();
          }
        },
        tooltip: 'Legg til habit',
        child: const Icon(Icons.add),
      ),

      body:
          habits.isEmpty
              ? const Center(child: Text('Ingen vaner funnet'))
              : ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return HabitCard(
                    title: habit['title'],
                    subtitle: habit['subtitle'],
                    color: habit['color'],
                    icon: habit['icon'],
                    checked: habit['checked'],
                    heatmapColor: habit['heatmapColor'],
                    dates: habitDates[index] ?? [],
                    onCheck: (val) => _toggleHabitChecked(index),
                    onDelete: () async {
                      setState(() {
                        habits.removeAt(index);
                        habitDates.remove(index);
                      });
                      await _saveHabits();
                    },
                    onEdit: () async {
                      String title = habit['title'];
                      String subtitle = habit['subtitle'];
                      int iconIndex = habit['iconIndex'];
                      Color color = habit['color'];
                      final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: const Text('Rediger vane'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Title',
                                        ),
                                        controller: TextEditingController(
                                          text: title,
                                        ),
                                        onChanged: (v) => title = v,
                                      ),
                                      TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Description',
                                        ),
                                        controller: TextEditingController(
                                          text: subtitle,
                                        ),
                                        onChanged: (v) => subtitle = v,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Velg ikon:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      IconPicker(
                                        selectedIndex: iconIndex,
                                        onSelect:
                                            (i) =>
                                                setState(() => iconIndex = i),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text('Avbryt'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop({
                                        'color': color,
                                        'icon': usedIcons[iconIndex],
                                        'iconIndex': iconIndex,
                                        'title': title,
                                        'subtitle': subtitle,
                                        'checked': habit['checked'],
                                        'heatmapColor': color,
                                      });
                                    },
                                    child: const Text('Lagre'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                      if (result != null) {
                        setState(() => habits[index] = result);
                        await _saveHabits();
                      }
                    },
                  );
                },
              ),
    );
  }
}
