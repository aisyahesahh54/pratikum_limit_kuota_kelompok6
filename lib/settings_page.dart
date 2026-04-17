import 'package:flutter/material.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [

          /// 🌙 DARK MODE
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Aktifkan mode gelap"),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),

        ],
      ),
    );
  }
}