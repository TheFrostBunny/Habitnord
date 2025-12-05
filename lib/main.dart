import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'theme_provider.dart';
import 'home_screen.dart';
import 'hooks/translations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final lang = prefs.getString('language') ?? 'no';
  await Translations.load(lang);
  runApp(const HabitNordRoot());
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

Future<Map<String, dynamic>> loadTranslations(String locale) async {
  final data = await rootBundle.loadString('assets/i18n/$locale.json');
  return jsonDecode(data);
}
