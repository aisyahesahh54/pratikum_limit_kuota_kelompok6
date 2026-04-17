// home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pratikum_limit_kuota_kelompok6/src/core/data/database_helper.dart';

// (ISI HOMEPAGE KAMU DI SINI SAJA)

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int wifi = 0;
  int mobile = 0;

  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _loadData();

    _sub = DatabaseHelper.instance.onDataChanged.listen((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getHistory();

    if (data.isEmpty) return;

    final today = data.first;

    setState(() {
      wifi = today['wifi'] ?? 0;
      mobile = today['mobile'] ?? 0;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 MB";

    double mb = bytes / (1024 * 1024);

    if (mb >= 1024) {
      return "${(mb / 1024).toStringAsFixed(2)} GB";
    }

    return "${mb.toStringAsFixed(2)} MB";
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int total = wifi + mobile;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Monitoring"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _card("WiFi", _formatBytes(wifi), Icons.wifi),
            const SizedBox(height: 15),
            _card("Mobile", _formatBytes(mobile),
                Icons.signal_cellular_alt),
            const SizedBox(height: 15),
            _card("Total", _formatBytes(total), Icons.data_usage,
                isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String value, IconData icon,
      {bool isBold = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16)),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isBold ? 22 : 18,
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}