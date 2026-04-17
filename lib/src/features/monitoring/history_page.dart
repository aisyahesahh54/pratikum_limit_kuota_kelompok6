import 'package:flutter/material.dart';
import 'package:pratikum_limit_kuota_kelompok6/src/core/data/database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<Map<String, dynamic>>>? _historyList;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    _historyList = DatabaseHelper.instance.getHistory();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Penggunaan"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Belum ada riwayat data 📭"),
            );
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              final wifi = item['wifi'] as int;
              final mobile = item['mobile'] as int;
              final total = wifi + mobile;

              /// 🔥 LIMIT (1GB)
              final limit = 1024 * 1024 * 1024;

              double percentage = (total / limit) * 100;

              String status;
              Color statusColor;

              if (percentage >= 90) {
                status = "Bahaya ⚠️";
                statusColor = Colors.red;
              } else if (percentage >= 70) {
                status = "Waspada ⚡";
                statusColor = Colors.orange;
              } else {
                status = "Aman ✅";
                statusColor = Colors.green;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).brightness ==
                          Brightness.dark
                      ? Colors.grey[900]
                      : Colors.grey[200],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 📅 TANGGAL
                    Text(
                      item['date'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// WIFI
                    Text("WiFi: ${_formatBytes(wifi)}"),

                    /// MOBILE
                    Text("Mobile: ${_formatBytes(mobile)}"),

                    /// TOTAL
                    Text(
                      "Total: ${_formatBytes(total)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 📊 PERSENTASE
                    Text(
                      "Pemakaian: ${percentage.toStringAsFixed(1)}%",
                    ),

                    /// 🚨 STATUS
                    Text(
                      "Status: $status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 📉 PROGRESS BAR
                    LinearProgressIndicator(
                      value: (percentage / 100).clamp(0, 1),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}