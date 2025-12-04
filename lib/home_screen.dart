import 'package:flutter/material.dart';
import 'habit_card.dart';
import 'habit_storage.dart';
import 'app_bar.dart';
import 'pages/settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> habits = [];
  final HabitStorage habitStorage = HabitStorage();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
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
  }

  void _toggleHabitChecked(int index) {
    setState(() {
      habits[index]['checked'] = !(habits[index]['checked'] as bool);
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
        title: 'HabitNord',
        leadingIcon: Icons.settings,
        onLeadingTap: () async {
          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => SettingsPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
          IconData icon = Icons.star;
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Habit'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        onChanged: (v) => title = v,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Description'),
                        onChanged: (v) => subtitle = v,
                      ),
                      // You can add dropdowns for color and icon here
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
                          'icon': icon,
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
      body: habits.isEmpty
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
                );
              },
            ),
    );
  }
}
