import "package:flutter/material.dart";

void main() {
  runApp(const HabitNordApp());
}

class HabitNordApp extends StatelessWidget {
  const HabitNordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitNord',
      themeMode: ThemeMode.system,
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),

      home: Scaffold(appBar: AppBar(title: const Text('HabitNord'))),
    );
  }
}
