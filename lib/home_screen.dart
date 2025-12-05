import 'package:flutter/material.dart';
import 'habit_card.dart';
import 'habit_storage.dart';
import 'app_bar.dart';
import 'pages/settings_page.dart';
import 'hooks/translations.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadHabitDates();
  }

  Future<void> _loadHabits() async {
    await habitStorage.initFile();
    final loadedHabits = await habitStorage.loadHabits();
    if (loadedHabits.isEmpty) {
      loadedHabits.addAll([
        {
          'color': Colors.purple[400]!,
          'icon': Icons.self_improvement,
          'title': 'Meditation',
          'subtitle': 'Meditate for 10 minutes',
          'checked': false,
          'heatmapColor': Colors.purpleAccent,
        },
        {
          'color': Colors.amber[700]!,
          'icon': Icons.code,
          'title': 'Code Daily',
          'subtitle': 'Write code for at least 1 hour',
          'checked': false,
          'heatmapColor': Colors.amberAccent,
        },
        {
          'color': Colors.blue[400]!,
          'icon': Icons.music_note,
          'title': 'Play Drums',
          'subtitle': 'Exercise drumming for at least 30 minutes',
          'checked': false,
          'heatmapColor': Colors.blueAccent,
        },
      ]);
      await habitStorage.saveHabits(loadedHabits);
    }
    setState(() {
      habits = loadedHabits;
      isLoading = false;
    });
  }

  Future<void> _saveHabits() async {
    await habitStorage.saveHabits(habits);
    // Lagre habitDates også
    // Konverter habitDates til en serialiserbar form
    final datesMap = habitDates.map(
      (key, value) => MapEntry(
        key.toString(),
        value.map((d) => d.toIso8601String()).toList(),
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('habitDates', jsonEncode(datesMap));
  }

  Future<void> _loadHabitDates() async {
    final prefs = await SharedPreferences.getInstance();
    final datesJson = prefs.getString('habitDates');
    if (datesJson != null) {
      final decoded = jsonDecode(datesJson) as Map<String, dynamic>;
      habitDates = decoded.map(
        (key, value) => MapEntry(
          int.parse(key),
          (value as List).map((s) => DateTime.parse(s)).toList(),
        ),
      );
    }
  }

  void _toggleHabitChecked(int index) {
    setState(() {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      habits[index]['checked'] = !(habits[index]['checked'] as bool);
      habitDates.putIfAbsent(index, () => []);
      if (habits[index]['checked']) {
        final alreadyLogged = habitDates[index]!.any(
          (d) =>
              d.year == todayDate.year &&
              d.month == todayDate.month &&
              d.day == todayDate.day,
        );
        if (!alreadyLogged) {
          habitDates[index]!.add(todayDate);
        }
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: Translations.text('app_title'),
        leadingIcon: Icons.settings,
        onLeadingTap: () async {
          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => SettingsPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                final tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
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
          // Add habit dialog
          String title = '';
          String subtitle = '';
          Color color = Colors.blue;
          int iconIndex = 0;
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text(Translations.text('add_habit')),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: Translations.text('title'),
                            ),
                            onChanged: (v) => title = v,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: Translations.text('description'),
                            ),
                            onChanged: (v) => subtitle = v,
                          ),
                          DropdownButton<int>(
                            value: iconIndex,
                            items: List.generate(
                              usedIcons.length,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Icon(usedIcons[i]),
                              ),
                            ),
                            onChanged:
                                (i) => setState(() {
                                  iconIndex = i ?? 0;
                                }),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (title.isNotEmpty && subtitle.isNotEmpty) {
                            Navigator.of(context).pop({
                              'color': color,
                              'icon': usedIcons[iconIndex],
                              'iconIndex': iconIndex,
                              'title': title,
                              'subtitle': subtitle,
                              'checked': false,
                              'heatmapColor': color,
                            });
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
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
                      Color color = habit['color'];
                      int iconIndex =
                          habit.containsKey('iconIndex')
                              ? habit['iconIndex']
                              : usedIcons.indexOf(habit['icon']);
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
                                      DropdownButton<int>(
                                        value: iconIndex,
                                        items: List.generate(
                                          usedIcons.length,
                                          (i) => DropdownMenuItem(
                                            value: i,
                                            child: Icon(usedIcons[i]),
                                          ),
                                        ),
                                        onChanged:
                                            (i) => setState(() {
                                              iconIndex = i ?? 0;
                                            }),
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
                                      if (title.isNotEmpty &&
                                          subtitle.isNotEmpty) {
                                        Navigator.of(context).pop({
                                          'color': color,
                                          'icon': usedIcons[iconIndex],
                                          'iconIndex': iconIndex,
                                          'title': title,
                                          'subtitle': subtitle,
                                          'checked': habit['checked'],
                                          'heatmapColor': color,
                                        });
                                      }
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
                        setState(() {
                          habits[index] = result;
                        });
                        await _saveHabits();
                      }
                    },
                    dates: habitDates[index] ?? [],
                  );
                },
              ),
    );
  }
}
