import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitnord/main.dart';
import 'package:flutter/widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeMode = themeProvider.themeMode;
    final isDark = themeMode == ThemeMode.dark;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) => _onPopInvoked(didPop, context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Theme'),
              subtitle: Text(
                themeMode == ThemeMode.system
                    ? 'System'
                    : (isDark ? 'Dark' : 'Light'),
              ),
              trailing: DropdownButton<ThemeMode>(
                value: themeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                ],
                onChanged: (mode) {
                  if (mode != null) themeProvider.setThemeMode(mode);
                },
              ),
            ),
            const Divider(),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Notifications'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('HabitNord v1.0.0'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
  void _onPopInvoked(bool didPop, BuildContext context) {
    // Her kan du legge til din egen logikk når brukeren går tilbake
    // didPop == true hvis siden ble poppet, false hvis det ble blokkert
    print('Back gesture: $didPop'); // Denne linjen viser at callbacken fungerer
  }
}