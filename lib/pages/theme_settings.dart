import 'package:flutter/material.dart';
import 'package:kuwartrack/main.dart';
import 'package:kuwartrack/pages/settings.dart';

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Default'),
              subtitle: const Text('Follow device settings'),
              onTap: () {
                MyApp.of(context).changeTheme(ThemeMode.system);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Light'),
              subtitle: const Text('Force light mode'),
              onTap: () {
                MyApp.of(context).changeTheme(ThemeMode.light);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Dark'),
              subtitle: const Text('Force dark mode'),
              onTap: () {
                MyApp.of(context).changeTheme(ThemeMode.dark);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}