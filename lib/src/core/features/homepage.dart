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

  final int limit = 10 * 1024 * 1024 * 1024; // 10 GB

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  Future<void> _loadTodayData() async {
    try {
      final data = await DatabaseHelper.instance.getHistory();

      if (data.isNotEmpty) {
        final today = data.first;

        setState(() {
          wifi = _safeToInt(today['wifi']);
          mobile = _safeToInt(today['mobile']);
        });
      } else {
        setState(() {
          wifi = 0;
          mobile = 0;
        });
      }
    } catch (e) {
      debugPrint("Error load data: $e");
    }
  }

  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 MB";
    double mb = bytes / (1024 * 1024);
    if (mb > 1024) {
      return "${(mb / 1024).toStringAsFixed(2)} GB";
    }
    return "${mb.toStringAsFixed(2)} MB";
  }

  @override
  Widget build(BuildContext context) {
    int total = wifi + mobile;
    double progress = limit > 0 ? total / limit : 0;
    progress = progress.clamp(0, 1);

    Color progressColor =
        progress > 0.8 ? Colors.red : Colors.green;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadTodayData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            const Text(
              "Halo 👋",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 5),
            const Text(
              "Pantau penggunaan kuotamu hari ini",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 🔥 TOTAL CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF66BB6A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Penggunaan",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatBytes(total),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 📊 PROGRESS
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Penggunaan Kuota",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 12,
                          backgroundColor: Colors.grey[300],
                          color: progressColor,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 5),
                  Text(
                    "${_formatBytes(total)} / ${_formatBytes(limit)}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📶 WIFI & MOBILE
            Row(
              children: [
                Expanded(
                  child: _buildCard(
                    title: "WiFi",
                    value: _formatBytes(wifi),
                    icon: Icons.wifi,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCard(
                    title: "Mobile",
                    value: _formatBytes(mobile),
                    icon: Icons.network_cell,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🚨 SISA KUOTA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.data_usage, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Sisa Kuota: ${_formatBytes((limit - total).clamp(0, limit))}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(title),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}