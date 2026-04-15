import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pratikum_limit_kuota_kelompok6/src/core/data/database_helper.dart';
import 'package:pratikum_limit_kuota_kelompok6/src/core/services/intent_helper.dart';
import 'package:pratikum_limit_kuota_kelompok6/src/features/monitoring/history_page.dart';

class Network extends StatefulWidget {
  const Network({super.key});

  @override
  State<Network> createState() => _NetworkState();
}

class _NetworkState extends State<Network> {
  static const platform = MethodChannel('limit_kuota/channel');

  String wifiUsage = "0.00 MB";
  String mobileUsage = "0.00 MB";

  bool isDarkMode = false;
  String statusUsage = "Aman";

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() async {
    while (mounted) {
      await fetchUsage();
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  Future<void> fetchUsage() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getTodayUsage');

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      int wifiBytes = result['wifi'] ?? 0;
      int mobileBytes = result['mobile'] ?? 0;

      await DatabaseHelper.instance.insertOrUpdate(
        todayDate,
        wifiBytes,
        mobileBytes,
      );

      setState(() {
        wifiUsage = _formatBytes(wifiBytes);
        mobileUsage = _formatBytes(mobileBytes);
      });

      double totalMb =
          (wifiBytes + mobileBytes) / (1024 * 1024);

      setState(() {
        _updateStatus(totalMb);
      });

      checkLimitAndWarn(wifiBytes + mobileBytes);
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        _showPermissionDialog();
      }
    }
  }

  void _updateStatus(double totalMb) {
    if (totalMb >= 900) {
      statusUsage = "Bahaya ⚠️";
    } else if (totalMb >= 700) {
      statusUsage = "Waspada ⚡";
    } else if (totalMb >= 500) {
      statusUsage = "Aman ✅";
    } else if (totalMb >= 500) {
  }

}
  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0.00 MB";
    double mb = bytes / (1024 * 1024);
    if (mb > 1024) {
      return "${(mb / 1024).toStringAsFixed(2)} GB";
    }
    return "${mb.toStringAsFixed(2)} MB";
  }

  double _calculatePercentage(String value) {
    double number = double.tryParse(value.split(" ")[0]) ?? 0;
    double limit = 1024;
    return (number / limit).clamp(0, 1);
  }

  Color _getUsageColor(String value) {
    double number = double.tryParse(value.split(" ")[0]) ?? 0;
    if (number >= 900) return const Color.fromARGB(255, 212, 209, 11);
    if (number >= 700) return const Color.fromARGB(255, 190, 198, 255);
    return Colors.green;
  }

  String _totalUsage() {
    double wifi = double.tryParse(wifiUsage.split(" ")[0]) ?? 0;
    double mobile = double.tryParse(mobileUsage.split(" ")[0]) ?? 0;
    return "${(wifi + mobile).toStringAsFixed(2)} MB";
  }

  Future<void> checkLimitAndWarn(int currentUsage) async {
    int limitInBytes = 2024 * 2024 * 2024;

    if (currentUsage >= limitInBytes) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Batas Kuota Tercapai!"),
          content: const Text(
            "Penggunaan data Anda sudah mencapai limit. Aktifkan 'Set Data Limit' di pengaturan sistem.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Nanti"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                IntentHelper.openDataLimitSettings();
              },
              child: const Text("Buka Pengaturan"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? Colors.black : const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Monitoring Data'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Total Hari Ini: ${_totalUsage()}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Status: $statusUsage",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusUsage.contains("Bahaya")
                    ? Colors.red
                    : statusUsage.contains("Waspada")
                        ? Colors.orange
                        : Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: _calculatePercentage(_totalUsage()),
              minHeight: 10,
            ),

            const SizedBox(height: 20),

            _usageCard("WiFi Today", wifiUsage, Icons.wifi),
            const SizedBox(height: 20),
            _usageCard("Mobile Today", mobileUsage,
                Icons.signal_cellular_alt),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: fetchUsage,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _usageCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              color: _getUsageColor(value),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _calculatePercentage(value)),
            duration: const Duration(seconds: 1),
            builder: (context, val, _) {
              return LinearProgressIndicator(
                value: val,
                backgroundColor:
                    const Color.fromARGB(192, 194, 141, 18),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 165, 76, 2)),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Izin Diperlukan"),
          content: const Text(
            "Aplikasi membutuhkan izin akses penggunaan. Silakan aktifkan di pengaturan.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                fetchUsage();
              },
              child: const Text("Buka Pengaturan"),
            ),
          ],
        );
      },
    );
  }
}