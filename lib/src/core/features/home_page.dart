import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pratikum_limit_kuota_kelompok6/src/core/data/database_helper.dart';
import 'package:pratikum_limit_kuota_kelompok6/src/features/monitoring/history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int wifi = 0;
  int mobile = 0;

  List<Map<String, dynamic>> history = [];

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

    if (data.isEmpty) {
      setState(() {
        wifi = 50 * 1024 * 1024;
        mobile = 120 * 1024 * 1024;
        history = [];
      });
      return;
    }

    final today = data.first;

    setState(() {
      wifi = today['wifi'] ?? 0;
      mobile = today['mobile'] ?? 0;
      history = data;
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

  double _getPercentage(int total) {
    double limit = 1024 * 1024 * 1024; // 1GB
    return (total / limit).clamp(0, 1);
  }

  String _getStatus(int total) {
    double mb = total / (1024 * 1024);

    if (mb >= 900) return "Bahaya ⚠️";
    if (mb >= 700) return "Waspada ⚡";
    return "Aman ✅";
  }

  Color _getStatusColor(int total) {
    double mb = total / (1024 * 1024);

    if (mb >= 900) return Colors.red;
    if (mb >= 700) return Colors.orange;
    return Colors.green;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int total = wifi + mobile;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Monitoring"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryPage(),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 TOTAL
            Text(
              "Total Hari Ini",
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 5),

            Text(
              _formatBytes(total),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 10),

            /// 📊 PROGRESS
            LinearProgressIndicator(
              value: _getPercentage(total),
              minHeight: 10,
            ),

            const SizedBox(height: 10),

            /// 🚨 STATUS
            Text(
              "Status: ${_getStatus(total)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(total),
              ),
            ),

            const SizedBox(height: 25),

            /// WIFI
            _card(
              context,
              "WiFi",
              _formatBytes(wifi),
              Icons.wifi,
              Colors.green,
            ),

            const SizedBox(height: 15),

            /// MOBILE
            _card(
              context,
              "Mobile",
              _formatBytes(mobile),
              Icons.signal_cellular_alt,
              Colors.blue,
            ),

            const SizedBox(height: 30),

            /// 🔥 HISTORY
            Text(
              "Riwayat Terbaru",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 10),

            if (history.isEmpty)
              const Text("Belum ada data 📭")
            else
              ...history.take(3).map((item) {
                int wifi = item['wifi'] ?? 0;
                int mobile = item['mobile'] ?? 0;
                int total = wifi + mobile;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['date']),
                      Text(_formatBytes(total)),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}