import 'package:flutter/material.dart';
import 'habit_card.dart';
import 'habit_storage.dart';

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
    return ListView.builder(
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
    );
  }
}
