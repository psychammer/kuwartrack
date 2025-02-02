import 'package:flutter/material.dart';
import 'package:kuwartrack/pages/home.dart';
import 'package:kuwartrack/pages/load_login.dart';
import 'package:kuwartrack/pages/login.dart';
import 'package:kuwartrack/pages/settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode; // Added getter

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuwartrack',
      theme: ThemeData(), // Default light theme
      darkTheme: ThemeData.dark(), // Standard dark theme
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => Login(),
        '/home': (context) => Home(),
        '/load_login': (context) => LoadLogin(),
        '/settings': (context) => Settings(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}