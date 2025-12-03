import "package:flutter/material.dart";
import 'habit_card.dart';
import 'translations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_bar.dart';
import 'pages/settings_page.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
  List<Map<String, dynamic>> habits = [
    {
      'color': Colors.purple[400]!,
      'icon': Icons.self_improvement,
      'title': 'Meditation',
      'subtitle': 'Meditate for 10 minutes',
      'checked': true,
      'heatmapColor': Colors.purpleAccent,
    },
    {
      'color': Colors.amber[700]!,
      'icon': Icons.code,
      'title': 'Code Daily',
      'subtitle': 'Write code for at least 1 hour',
      'checked': true,
      'heatmapColor': Colors.amberAccent,
    },
    {
      'color': Colors.blue[400]!,
      'icon': Icons.music_note,
      'title': 'Play Drums',
      'subtitle': 'Exercise drumming for at least 30 minutes',
      'checked': true,
      'heatmapColor': Colors.blueAccent,
    },
    {
      'color': Colors.green[700]!,
      'icon': Icons.directions_run,
      'title': 'Running',
      'subtitle': 'Go for a jog every other day',
      'checked': true,
      'heatmapColor': Colors.greenAccent,
    },
    {
      'color': Colors.pink[400]!,
      'icon': Icons.coffee,
      'title': 'Limit Coffee Intake',
      'subtitle': 'Drink a maximum of two cups a day',
      'checked': true,
      'heatmapColor': Colors.pinkAccent,
    },
  ];

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
              color: habit['color'],
              icon: habit['icon'],
              title: habit['title'],
              subtitle: habit['subtitle'],
              checked: habit['checked'],
              heatmapColor: habit['heatmapColor'],
              onCheck: (val) {
                setState(() {
                  habits[index]['checked'] = val;
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
        tooltip: 'Add Habit',
      ),
    );
  }
}

Future<Map<String, dynamic>> loadTranslations(String locale) async {
  final data = await rootBundle.loadString('assets/i18n/$locale.json');
  return jsonDecode(data);
}
