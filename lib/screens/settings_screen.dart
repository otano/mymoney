import 'package:flutter/material.dart';
class SettingsScreen extends StatelessWidget {
  final bool darkMode;
  final String devise;
  final Function(bool) onThemeChanged;
  final Function(String) onDeviseChanged;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.devise,
    required this.onThemeChanged,
    required this.onDeviseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Paramètres")),
      body: Column(
        children: [
          SwitchListTile(
            title: Text("Mode sombre"),
            value: darkMode,
            onChanged: onThemeChanged,
          ),
          DropdownButton<String>(
            value: devise,
            items: ["€", "\$"]
                .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ))
                .toList(),
            onChanged: (val) {
              if (val != null) onDeviseChanged(val);
            },
          )
        ],
      ),
    );
  }
}