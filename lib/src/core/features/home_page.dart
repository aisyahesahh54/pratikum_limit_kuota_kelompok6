import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pratikum_limit_kuota_kelompok6/src/core/data/database_helper.dart';

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

    // 🔥 REAL-TIME LISTENER
    _sub = DatabaseHelper.instance.onDataChanged.listen((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getHistory();

    if (data.isEmpty) return;

    final today = data.first; // aman karena sudah dicek

    if (!mounted) return;

    setState(() {
      wifi = _safeToInt(today['wifi']);
      mobile = _safeToInt(today['mobile']);
    });
  }

  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
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
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Total Hari Ini: ${_formatBytes(total)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}