import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repository/habit_repository.dart';
import 'services/storage_service.dart';
import 'models/habit.dart';
import 'widgets/calendar_view.dart';

void main() {
  runApp(const HabitNordApp());
}

class HabitNordApp extends StatelessWidget {
  const HabitNordApp({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = _habitNordPalette;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HabitRepository(StorageService())..load(),
        ),
      ],
      child: MaterialApp(
        title: 'HabitNord',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: palette.primary),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const HabitsHomePage(),
      ),
    );
  }
}

class HabitsHomePage extends StatelessWidget {
  const HabitsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HabitRepository>();
    final habits = repo.habits;
    return Scaffold(
      appBar: AppBar(title: const Text('HabitNord')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dine vaner',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    await _showAddHabitDialog(context);
                  },
                ),
              ],
            ),
          ),
          ...habits.map((h) => _HabitTile(habit: h)),
          const SizedBox(height: 16),
          const ContributionsSection(),
        ],
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final Habit habit;
  const _HabitTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HabitRepository>();
    final today = DateTime.now();
    final completedToday = repo.logs.any(
      (l) =>
          l.habitId == habit.id &&
          l.date.year == today.year &&
          l.date.month == today.month &&
          l.date.day == today.day,
    );
    return ListTile(
      leading: CircleAvatar(backgroundColor: _colorFromHex(habit.colorHex)),
      title: Text(habit.name),
      subtitle: Text('Trykk for kalender'),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _HabitCalendarScreen(habit: habit)),
        );
      },
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'edit') {
            await _showEditHabitDialog(context, habit);
          } else if (value == 'delete') {
            await repo.deleteHabit(habit);
          } else if (value == 'toggle') {
            await repo.toggleCompletion(habit, DateTime.now());
          }
        },
        itemBuilder:
            (ctx) => const [
              PopupMenuItem(value: 'toggle', child: Text('Marker i dag')),
              PopupMenuItem(value: 'edit', child: Text('Rediger')),
              PopupMenuItem(value: 'delete', child: Text('Slett')),
            ],
      ),
    );
  }
}

class ContributionsSection extends StatelessWidget {
  const ContributionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7 * 52));
    final repo = context.watch<HabitRepository>();
    final habits = repo.habits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final h in habits) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Bidrag for: ${h.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _ContributionsHeatmap(start: start, end: end, habitId: h.id),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _HabitCalendarScreen extends StatelessWidget {
  final Habit habit;
  const _HabitCalendarScreen({required this.habit});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: Text(habit.name)),
      body: ListView(
        children: [
          MonthlyCalendarView(
            habit: habit,
            month: DateTime(now.year, now.month),
          ),
        ],
      ),
    );
  }
}

// Comparison UI removed per request

class _ContributionsHeatmap extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final String? habitId;
  const _ContributionsHeatmap({
    required this.start,
    required this.end,
    this.habitId,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HabitRepository>();
    final palette = _habitNordPalette;
    // Prepare weeks columns similar to GitHub
    final columns = <List<DateTime>>[];
    var cursor = start;
    // Align start to previous Sunday
    cursor = cursor.subtract(Duration(days: cursor.weekday % 7));
    while (!cursor.isAfter(end)) {
      final week = <DateTime>[];
      for (int i = 0; i < 7; i++) {
        final day = cursor.add(Duration(days: i));
        if (!day.isBefore(start) && !day.isAfter(end)) {
          week.add(day);
        } else {
          week.add(day);
        }
      }
      columns.add(week);
      cursor = cursor.add(const Duration(days: 7));
    }

    // Build per-day counts filtered by habit when provided
    final Map<DateTime, int> perDay = {};
    for (final l in repo.logs) {
      if (habitId != null && l.habitId != habitId) continue;
      if (l.date.isBefore(start) || l.date.isAfter(end)) continue;
      final key = DateTime(l.date.year, l.date.month, l.date.day);
      perDay[key] = (perDay[key] ?? 0) + 1;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final week in columns)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Column(
                children: [
                  for (final day in week)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: _HeatCell(
                        date: day,
                        count:
                            perDay[DateTime(day.year, day.month, day.day)] ?? 0,
                        palette: palette,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  final DateTime date;
  final int count;
  final _Palette palette;
  const _HeatCell({
    required this.date,
    required this.count,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForCount(count, palette);
    return Tooltip(
      message: '${date.year}-${date.month}-${date.day}: $count',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

Future<void> _showAddHabitDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final colors = _habitNordPalette.swatches;
  String selectedHex = _habitNordPalette.primaryHex;
  final repo = context.read<HabitRepository>();
  await showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Ny vane'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Navn'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final hex in colors)
                    GestureDetector(
                      onTap: () {
                        selectedHex = hex;
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _colorFromHex(hex),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                hex == selectedHex
                                    ? Colors.black
                                    : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Avbryt'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await repo.addHabit(name, selectedHex);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Lagre'),
            ),
          ],
        ),
  );
}

Future<void> _showEditHabitDialog(BuildContext context, Habit habit) async {
  final nameController = TextEditingController(text: habit.name);
  final colors = _habitNordPalette.swatches;
  String selectedHex = habit.colorHex;
  final repo = context.read<HabitRepository>();
  await showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Rediger vane'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Navn'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final hex in colors)
                    GestureDetector(
                      onTap: () {
                        selectedHex = hex;
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _colorFromHex(hex),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                hex == selectedHex
                                    ? Colors.black
                                    : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Avbryt'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await repo.updateHabit(
                    habit,
                    name: name,
                    colorHex: selectedHex,
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Lagre'),
            ),
          ],
        ),
  );
}

class _Palette {
  final Color primary;
  final String primaryHex;
  final List<String> swatches;
  const _Palette({
    required this.primary,
    required this.primaryHex,
    required this.swatches,
  });
}

const _habitNordPalette = _Palette(
  primary: Color(0xFF1E3A8A),
  primaryHex: '1E3A8A',
  swatches: [
    '1E3A8A', // deep blue
    '2563EB', // blue
    '10B981', // teal
    'F59E0B', // amber
    'EF4444', // red
    '8B5CF6', // violet
  ],
);

Color _colorFromHex(String hex) {
  final v = hex.replaceAll('#', '');
  return Color(int.parse('FF$v', radix: 16));
}

Color _colorForCount(int count, _Palette palette) {
  if (count <= 0) return const Color(0xFFE5E7EB); // gray-200
  if (count == 1) return const Color(0xFFBFDBFE); // blue-200
  if (count <= 3) return const Color(0xFF60A5FA); // blue-400
  if (count <= 6) return const Color(0xFF2563EB); // blue-600
  return const Color(0xFF1E3A8A); // blue-800
}
