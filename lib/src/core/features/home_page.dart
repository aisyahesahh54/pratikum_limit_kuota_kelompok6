import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:pratikum_limit_kuota_kelompok6/src/core/data/database_helper.dart';
import 'package:pratikum_limit_kuota_kelompok6/src/features/monitoring/history_page.dart';
>>>>>>> 28e9879b5e29b3b6cbe4d6edad1a9186846cef46

void main() {
  runApp(const MyApp());
}

<<<<<<< HEAD
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double used = 6; // contoh pemakaian
    double total = 10;

    double percent = used / total;

    Color getColor() {
      if (percent < 0.5) return Colors.green;
      if (percent < 0.8) return Colors.orange;
      return Colors.red;
    }
=======
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
>>>>>>> 28e9879b5e29b3b6cbe4d6edad1a9186846cef46

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Monitoring Kuota",
          style: TextStyle(color: Colors.black),
        ),
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
<<<<<<< HEAD
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= CARD UTAMA =================
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    getColor().withOpacity(0.7),
                    getColor(),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: getColor().withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Row(
                    children: const [
                      Icon(Icons.wifi, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Limit Kuota",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // SISA KUOTA
                  Text(
                    "${(total - used)} GB tersisa",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PROGRESS BAR
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${(percent * 100).toStringAsFixed(0)}% digunakan",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= MENU CEPAT =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _menuItem(Icons.data_usage, "Data"),
                _menuItem(Icons.bar_chart, "Statistik"),
                _menuItem(Icons.notifications, "Notif"),
                _menuItem(Icons.settings, "Setting"),
              ],
=======
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
>>>>>>> 28e9879b5e29b3b6cbe4d6edad1a9186846cef46
            ),

            const SizedBox(height: 25),

<<<<<<< HEAD
            // ================= LIST MONITORING =================
            Expanded(
              child: ListView(
                children: const [
                  MonitoringTile(
                    icon: Icons.today,
                    title: "Pemakaian Hari Ini",
                    value: "700 MB",
                  ),
                  MonitoringTile(
                    icon: Icons.date_range,
                    title: "Pemakaian Mingguan",
                    value: "3 GB",
                  ),
                  MonitoringTile(
                    icon: Icons.warning,
                    title: "Batas Harian",
                    value: "1 GB",
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // MENU ICON
  Widget _menuItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
              )
            ],
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }
}

// ================= TILE =================
class MonitoringTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const MonitoringTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
=======
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
>>>>>>> 28e9879b5e29b3b6cbe4d6edad1a9186846cef46
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