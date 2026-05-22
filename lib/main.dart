
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  bool darkMode = false;
  String devise = "€";

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
      devise = prefs.getString('devise') ?? "€";
    });
  }

  void toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = value;
    });

    prefs.setBool('darkMode', value);
  }

  void changeDevise(String value) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      devise = value;
    });

    prefs.setString('devise', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dépenses',
      theme: darkMode ? ThemeData.dark() : ThemeData.light(),
      routes: {
        "/": (ctx) => HomeScreen(devise: devise),
        "/settings": (ctx) => SettingsScreen(
          darkMode: darkMode,
          devise: devise,
          onThemeChanged: toggleTheme,
          onDeviseChanged: changeDevise,
        ),
      },
    );
  }
}