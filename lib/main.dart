import "package:flutter/material.dart";
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'habit_card.dart';
import 'translations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_bar.dart';
import 'pages/settings_page.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

// List all icons used dynamically so Flutter includes them in the build
final Set<IconData> usedIcons = {
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
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final lang = prefs.getString('language') ?? 'no';
  await Translations.load(lang);
  runApp(const HabitNordRoot());
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode');
    if (themeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
  }
}

class HabitNordRoot extends StatelessWidget {
  const HabitNordRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const HabitNordApp(),
    );
  }
}

class HabitNordApp extends StatelessWidget {
  const HabitNordApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'HabitNord',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> habits = [];
  late File habitsFile;

  @override
  void initState() {
    super.initState();
    _initHabitsFile();
  }

  Future<void> _initHabitsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    habitsFile = File('${dir.path}/habits.json');
    await _loadHabits();
  }

  Future<void> _loadHabits() async {
    if (await habitsFile.exists()) {
      final contents = await habitsFile.readAsString();
      final decoded = jsonDecode(contents) as List;
      setState(() {
        habits =
            decoded.map<Map<String, dynamic>>((h) {
              return {
                'color': Color(h['color'] as int),
                'icon': IconData(h['icon'] as int, fontFamily: 'MaterialIcons'),
                'title': h['title'],
                'subtitle': h['subtitle'],
                'checked': h['checked'],
                'heatmapColor': Color(h['heatmapColor'] as int),
              };
            }).toList();
      });
    } else {
      habits = [
        {
          'color': Colors.purple[400]!.toARGB32(),
          'icon': Icons.self_improvement.codePoint,
          'title': 'Meditation',
          'subtitle': 'Meditate for 10 minutes',
          'checked': true,
          'heatmapColor': Colors.purpleAccent.toARGB32(),
        },
        {
          'color': Colors.amber[700]!.toARGB32(),
          'icon': Icons.code.codePoint,
          'title': 'Code Daily',
          'subtitle': 'Write code for at least 1 hour',
          'checked': true,
          'heatmapColor': Colors.amberAccent.toARGB32(),
        },
        {
          'color': Colors.blue[400]!.toARGB32(),
          'icon': Icons.music_note.codePoint,
          'title': 'Play Drums',
          'subtitle': 'Exercise drumming for at least 30 minutes',
          'checked': true,
          'heatmapColor': Colors.blueAccent.toARGB32(),
        },
        {
          'color': Colors.green[700]!.toARGB32(),
          'icon': Icons.directions_run.codePoint,
          'title': 'Running',
          'subtitle': 'Go for a jog every other day',
          'checked': true,
          'heatmapColor': Colors.greenAccent.toARGB32(),
        },
        {
          'color': Colors.pink[400]!.toARGB32(),
          'icon': Icons.coffee.codePoint,
          'title': 'Limit Coffee Intake',
          'subtitle': 'Drink a maximum of two cups a day',
          'checked': true,
          'heatmapColor': Colors.pinkAccent.toARGB32(),
        },
      ];
      await _saveHabits();
      setState(() {});
    }
  }

  Future<void> _saveHabits() async {
    final encoded = jsonEncode(
      habits
          .map(
            (h) => {
              'color':
                  h['color'] is Color
                      ? (h['color'] as Color).toARGB32()
                      : h['color'],
              'icon':
                  (h['icon'] is IconData)
                      ? (h['icon'] as IconData).codePoint
                      : h['icon'],
              'title': h['title'],
              'subtitle': h['subtitle'],
              'checked': h['checked'],
              'heatmapColor':
                  h['heatmapColor'] is Color
                      ? (h['heatmapColor'] as Color).toARGB32()
                      : h['heatmapColor'],
            },
          )
          .toList(),
    );
    await habitsFile.writeAsString(encoded);
  }

  void _addHabit() async {
    Color color = Colors.blue;
    IconData icon = Icons.star;
    String title = '';
    String subtitle = '';
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
                DropdownButton<Color>(
                  value: color,
                  items: [
                    DropdownMenuItem(value: Colors.blue, child: Text('Blue')),
                    DropdownMenuItem(
                      value: Colors.purple,
                      child: Text('Purple'),
                    ),
                    DropdownMenuItem(
                      value: Colors.amber,
                      child: Text('Yellow'),
                    ),
                    DropdownMenuItem(value: Colors.green, child: Text('Green')),
                    DropdownMenuItem(value: Colors.pink, child: Text('Pink')),
                  ],
                  onChanged:
                      (c) => setState(() {
                        color = c ?? Colors.blue;
                      }),
                ),
                DropdownButton<IconData>(
                  value: icon,
                  items: [
                    DropdownMenuItem(
                      value: Icons.star,
                      child: Icon(Icons.star),
                    ),
                    DropdownMenuItem(
                      value: Icons.self_improvement,
                      child: Icon(Icons.self_improvement),
                    ),
                    DropdownMenuItem(
                      value: Icons.code,
                      child: Icon(Icons.code),
                    ),
                    DropdownMenuItem(
                      value: Icons.music_note,
                      child: Icon(Icons.music_note),
                    ),
                    DropdownMenuItem(
                      value: Icons.directions_run,
                      child: Icon(Icons.directions_run),
                    ),
                    DropdownMenuItem(
                      value: Icons.coffee,
                      child: Icon(Icons.coffee),
                    ),
                    DropdownMenuItem(
                      value: Icons.book,
                      child: Icon(Icons.book),
                    ),
                    DropdownMenuItem(
                      value: Icons.fitness_center,
                      child: Icon(Icons.fitness_center),
                    ),
                    DropdownMenuItem(
                      value: Icons.fastfood,
                      child: Icon(Icons.fastfood),
                    ),
                    DropdownMenuItem(
                      value: Icons.nightlight_round,
                      child: Icon(Icons.nightlight_round),
                    ),
                    DropdownMenuItem(
                      value: Icons.water_drop,
                      child: Icon(Icons.water_drop),
                    ),
                    DropdownMenuItem(
                      value: Icons.sunny,
                      child: Icon(Icons.sunny),
                    ),
                    DropdownMenuItem(
                      value: Icons.check_circle,
                      child: Icon(Icons.check_circle),
                    ),
                    DropdownMenuItem(
                      value: Icons.timer,
                      child: Icon(Icons.timer),
                    ),
                    DropdownMenuItem(
                      value: Icons.directions_bike,
                      child: Icon(Icons.directions_bike),
                    ),
                    DropdownMenuItem(value: Icons.spa, child: Icon(Icons.spa)),
                  ],
                  onChanged:
                      (i) => setState(() {
                        icon = i ?? Icons.star;
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
                    'icon': icon,
                    'title': title,
                    'subtitle': subtitle,
                    'checked': false,
                    'heatmapColor': color.toARGB32(),
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
        habits.add({
          'color': result['color'],
          'icon': (result['icon'] as IconData).codePoint,
          'title': result['title'],
          'subtitle': result['subtitle'],
          'checked': result['checked'],
          'heatmapColor': result['heatmapColor'],
        });
      });
      await _saveHabits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'HabitNord',
        leadingIcon: Icons.settings,
        onLeadingTap: () async {
          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const SettingsPage(),
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
          setState(() {});
        },
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HabitCard(
              color:
                  habit['color'] is Color
                      ? habit['color']
                      : Color(habit['color'] as int),
              icon:
                  habit['icon'] is IconData
                      ? habit['icon']
                      : IconData(habit['icon'], fontFamily: 'MaterialIcons'),
              title: habit['title'],
              subtitle: habit['subtitle'],
              checked: habit['checked'],
              heatmapColor:
                  habit['heatmapColor'] is Color
                      ? habit['heatmapColor']
                      : Color(habit['heatmapColor'] as int),
              onCheck: (val) {
                setState(() {
                  habits[index]['checked'] = val;
                });
                _saveHabits();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        tooltip: 'Add Habit',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<Map<String, dynamic>> loadTranslations(String locale) async {
  final data = await rootBundle.loadString('assets/i18n/$locale.json');
  return jsonDecode(data);
}
