import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

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
      ),
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
            ),

            const SizedBox(height: 25),

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
        ),
      ),
    );
  }
}