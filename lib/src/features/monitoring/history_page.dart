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

    if (mb > 1024) {
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

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.calendar_today,
                        color: Colors.blue),
                  ),
                  title: Text(
                    item['date'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.wifi,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 5),
                          Text("WiFi: ${_formatBytes(wifi)}"),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(Icons.network_cell,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 5),
                          Text("Mobile: ${_formatBytes(mobile)}"),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Total: ${_formatBytes(total)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}