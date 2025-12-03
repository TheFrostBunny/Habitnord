import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitnord/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitnord/translations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'no';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'no';
    final notif = prefs.getBool('notifications') ?? true;
    await Translations.load(lang);
    setState(() {
      _selectedLanguage = lang;
      _notificationsEnabled = notif;
    });
  }

  Future<void> _changeLanguage(String lang) async {
    await Translations.load(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() {
      _selectedLanguage = lang;
    });
  }

  Future<void> _changeNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeMode = themeProvider.themeMode;
    final isDark = themeMode == ThemeMode.dark;
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Translations.text('settings')),
          centerTitle: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(Translations.text('language')),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items: const [
                  DropdownMenuItem(value: 'no', child: Text('Norsk')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (lang) {
                  if (lang != null) _changeLanguage(lang);
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: Text(Translations.text('theme')),
              subtitle: Text(
                themeMode == ThemeMode.system
                    ? Translations.text('system')
                    : (isDark
                        ? Translations.text('dark')
                        : Translations.text('light')),
              ),
              trailing: DropdownButton<ThemeMode>(
                value: themeMode,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(Translations.text('system')),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(Translations.text('light')),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(Translations.text('dark')),
                  ),
                ],
                onChanged: (mode) {
                  if (mode != null) themeProvider.setThemeMode(mode);
                },
              ),
            ),
            const Divider(),
            SwitchListTile(
              value: _notificationsEnabled,
              onChanged: (val) => _changeNotifications(val),
              title: Text(Translations.text('notifications')),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(Translations.text('about')),
              subtitle: const Text('HabitNord v0.0.1'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
