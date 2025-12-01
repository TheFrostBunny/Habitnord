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
          colorScheme: ColorScheme.fromSeed(
            seedColor: palette.primary,
            brightness: Brightness.dark,
          ),
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          cardColor: const Color(0xFF111827),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: _colorFromHex(habit.colorHex),
          child: Icon(_iconForHabit(habit.iconName), color: Colors.white),
        ),
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if ((habit.description ?? '').isNotEmpty)
              Text(
                habit.description!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 10),
            _InlineHeatmap(habitId: habit.id, baseHex: habit.colorHex),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _HabitCalendarScreen(habit: habit),
            ),
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
              (ctx) => [
                const PopupMenuItem(
                  value: 'toggle',
                  child: Text('Marker i dag'),
                ),
                const PopupMenuItem(value: 'edit', child: Text('Rediger')),
                const PopupMenuItem(value: 'delete', child: Text('Slett')),
              ],
        ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bidrag for: ${h.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((h.description ?? '').isNotEmpty)
                  Text(
                    h.description!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 8),
                _ContributionsHeatmap(
                  start: start,
                  end: end,
                  habitId: h.id,
                  baseHex: h.colorHex,
                ),
              ],
            ),
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
      body: ListView(children: [MonthlyCalendarView(habit: habit, month: now)]),
    );
  }
}

class _ContributionsHeatmap extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final String? habitId;
  final String? baseHex;
  const _ContributionsHeatmap({
    required this.start,
    required this.end,
    this.habitId,
    this.baseHex,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HabitRepository>();
    final palette = _habitNordPalette;
    final columns = <List<DateTime>>[];
    var cursor = start;
    final daysToMonday =
        (cursor.weekday == DateTime.monday)
            ? 0
            : (cursor.weekday == DateTime.sunday ? 6 : cursor.weekday - 1);
    cursor = cursor.subtract(Duration(days: daysToMonday));
    while (!cursor.isAfter(end)) {
      final week = <DateTime>[];
      for (int i = 0; i < 7; i++) {
        final day = cursor.add(Duration(days: i));
        week.add(day);
      }
      columns.add(week);
      cursor = cursor.add(const Duration(days: 7));
    }

    final Map<DateTime, int> perDay = {};
    for (final l in repo.logs) {
      if (habitId != null && l.habitId != habitId) continue;
      if (l.date.isBefore(start) || l.date.isAfter(end)) continue;
      final key = DateTime(l.date.year, l.date.month, l.date.day);
      perDay[key] = (perDay[key] ?? 0) + 1;
    }

    final monthLabels = <Widget>[];
    DateTime? lastMonth;
    for (final week in columns) {
      final first = week.first;
      final m = DateTime(first.year, first.month);
      if (lastMonth == null || m.month != lastMonth.month) {
        monthLabels.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              _monthShort(m.month),
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
        lastMonth = m;
      } else {
        monthLabels.add(const SizedBox(width: 16));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: monthLabels),
          const SizedBox(height: 4),
          Row(
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
                                perDay[DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                )] ??
                                0,
                            palette: palette,
                            baseHex: baseHex,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _monthShort(int m) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mai',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return names[m - 1];
}

class _HeatCell extends StatelessWidget {
  final DateTime date;
  final int count;
  final _Palette palette;
  final String? baseHex;
  const _HeatCell({
    required this.date,
    required this.count,
    required this.palette,
    this.baseHex,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForCount(count, palette, baseHex: baseHex);
    return Tooltip(
      message: '${date.year}-${date.month}-${date.day}: $count',
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _InlineHeatmap extends StatelessWidget {
  final String habitId;
  final String baseHex;
  const _InlineHeatmap({required this.habitId, required this.baseHex});
  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HabitRepository>();
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7 * 12));
    final columns = <List<DateTime>>[];
    var cursor = start;
    final daysToMonday =
        (cursor.weekday == DateTime.monday)
            ? 0
            : (cursor.weekday == DateTime.sunday ? 6 : cursor.weekday - 1);
    cursor = cursor.subtract(Duration(days: daysToMonday));
    while (!cursor.isAfter(end)) {
      final week = <DateTime>[];
      for (int i = 0; i < 7; i++) {
        week.add(cursor.add(Duration(days: i)));
      }
      columns.add(week);
      cursor = cursor.add(const Duration(days: 7));
    }

    final Map<DateTime, int> perDay = {};
    for (final l in repo.logs) {
      if (l.habitId != habitId) continue;
      if (l.date.isBefore(start) || l.date.isAfter(end)) continue;
      final key = DateTime(l.date.year, l.date.month, l.date.day);
      perDay[key] = (perDay[key] ?? 0) + 1;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: SizedBox(
        height: 60,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final week in columns)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final day in week)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1.0),
                          child: _MiniCell(
                            color: _colorForCount(
                              perDay[DateTime(day.year, day.month, day.day)] ??
                                  0,
                              _habitNordPalette,
                              baseHex: baseHex,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Removed unused _QuickToggleButton widget

IconData _iconForHabit(String? name) {
  switch (name) {
    case 'run':
      return Icons.directions_run;
    case 'code':
      return Icons.code;
    case 'book':
      return Icons.menu_book;
    case 'music':
      return Icons.music_note;
    case 'coffee':
      return Icons.coffee;
    case 'meditate':
      return Icons.self_improvement;
    default:
      return Icons.check;
  }
}

class _MiniCell extends StatelessWidget {
  final Color color;
  const _MiniCell({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

Future<void> _showAddHabitDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final iconNames = const [
    'run',
    'code',
    'book',
    'music',
    'coffee',
    'meditate',
  ];
  String selectedIcon = 'run';
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
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Beskrivelse (valgfritt)',
                ),
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final n in iconNames)
                    ChoiceChip(
                      label: Icon(_iconForHabit(n), size: 16),
                      selected: selectedIcon == n,
                      onSelected: (_) => selectedIcon = n,
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
                final desc = descController.text.trim();
                if (name.isNotEmpty) {
                  await repo.addHabit(
                    name,
                    selectedHex,
                    description: desc.isEmpty ? null : desc,
                    iconName: selectedIcon,
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

Future<void> _showEditHabitDialog(BuildContext context, Habit habit) async {
  final nameController = TextEditingController(text: habit.name);
  final descController = TextEditingController(text: habit.description ?? '');
  final iconNames = const [
    'run',
    'code',
    'book',
    'music',
    'coffee',
    'meditate',
  ];
  String selectedIcon = habit.iconName ?? 'run';
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
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Beskrivelse (valgfritt)',
                ),
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final n in iconNames)
                    ChoiceChip(
                      label: Icon(_iconForHabit(n), size: 16),
                      selected: selectedIcon == n,
                      onSelected: (_) => selectedIcon = n,
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
                final desc = descController.text.trim();
                if (name.isNotEmpty) {
                  await repo.updateHabit(
                    habit,
                    name: name,
                    colorHex: selectedHex,
                    description: desc.isEmpty ? null : desc,
                    iconName: selectedIcon,
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
  swatches: ['1E3A8A', '2563EB', '10B981', 'F59E0B', 'EF4444', '8B5CF6'],
);

Color _colorFromHex(String hex) {
  final v = hex.replaceAll('#', '');
  return Color(int.parse('FF$v', radix: 16));
}

Color _colorForCount(int count, _Palette palette, {String? baseHex}) {
  final base = baseHex != null ? _colorFromHex(baseHex) : palette.primary;
  if (count <= 0) return const Color(0xFF1F2937);
  final levels = [0.25, 0.45, 0.65, 0.85, 1.0];
  final idx =
      count <= 1
          ? 1
          : count <= 3
          ? 2
          : count <= 6
          ? 3
          : 4;
  return _tint(base, levels[idx]);
}

Color _tint(Color base, double strength) {
  final r = (base.r * strength + 255 * (1 - strength)).round();
  final g = (base.g * strength + 255 * (1 - strength)).round();
  final b = (base.b * strength + 255 * (1 - strength)).round();
  return Color.fromARGB(255, r, g, b);
}
