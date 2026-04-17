import 'package:flutter/material.dart';
import 'package:pratikum_limit_kuota_kelompok6/src/core/data/database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<Map<String, dynamic>>>? _historyList;

  List<Map<String, dynamic>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() async {
    final data = await DatabaseHelper.instance.getHistory();
    setState(() {
      _filteredData = data;
      _historyList = Future.value(data);
    });
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: const Text("Riwayat Penggunaan")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada riwayat data."));
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Color.fromARGB(255, 33, 233, 243)),
                  title: Text(
                    item['date'], // Tanggal (YYYY-MM-DD)
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("WiFi: ${_formatBytes(item['wifi'])}"),
                      Text("Mobile: ${_formatBytes(item['mobile'])}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
=======
      appBar: AppBar(
        title: const Text("Riwayat Penggunaan"),
        centerTitle: true,
>>>>>>> aab86ec13858046dbe37434fdee1b872e2460278
      ),
      body: _historyList == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _historyList,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                // 🔥 GANTI pakai _filteredData
                if (_filteredData.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada riwayat data 📭",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _filteredData.length,
                  itemBuilder: (context, index) {
                    final item = _filteredData[index];

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
                            color: const Color.fromARGB(
                              255,
                              15,
                              147,
                              213,
                            ).withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                          ),
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

                            // WIFI
                            Row(
                              children: [
                                const Icon(
                                  Icons.wifi,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 5),
                                Text("WiFi: ${_formatBytes(wifi)}"),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // MOBILE
                            Row(
                              children: [
                                const Icon(
                                  Icons.network_cell,
                                  size: 16,
                                  color: Color.fromARGB(255, 243, 8, 203),
                                ),
                                const SizedBox(width: 5),
                                Text("Mobile: ${_formatBytes(mobile)}"),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // TOTAL
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
