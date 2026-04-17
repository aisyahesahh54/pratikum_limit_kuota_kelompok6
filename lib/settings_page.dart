import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notif = true;
  bool darkMode = false;

  int wifiLimit = 1000; // MB
  int mobileLimit = 500; // MB

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// 🔔 NOTIFICATION
          SwitchListTile(
            title: const Text("Notifikasi"),
            subtitle: const Text("Aktifkan peringatan penggunaan"),
            value: notif,
            onChanged: (value) {
              setState(() {
                notif = value;
              });
            },
          ),

          const Divider(),

          /// 🌙 DARK MODE
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Tema gelap"),
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
          ),

          const Divider(),

          /// 📶 WIFI LIMIT
          ListTile(
            title: const Text("Limit WiFi"),
            subtitle: Text("$wifiLimit MB"),
            trailing: const Icon(Icons.edit),
            onTap: () => _editLimit("WiFi"),
          ),

          /// 📡 MOBILE LIMIT
          ListTile(
            title: const Text("Limit Mobile"),
            subtitle: Text("$mobileLimit MB"),
            trailing: const Icon(Icons.edit),
            onTap: () => _editLimit("Mobile"),
          ),

          const Divider(),

          /// ℹ️ ABOUT
          ListTile(
            title: const Text("Tentang Aplikasi"),
            subtitle: const Text("Monitoring Kuota v1.0"),
            leading: const Icon(Icons.info),
          ),
        ],
      ),
    );
  }

  void _editLimit(String type) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Set Limit $type"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Masukkan dalam MB",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                int value = int.tryParse(controller.text) ?? 0;

                if (type == "WiFi") {
                  wifiLimit = value;
                } else {
                  mobileLimit = value;
                }
              });

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}