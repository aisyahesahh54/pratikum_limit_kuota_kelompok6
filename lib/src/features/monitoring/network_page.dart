import 'dart:async';
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

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    fetchUsage(); // 🔥 langsung ambil data pertama

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchUsage();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchUsage() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getTodayUsage');

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      int wifiBytes = result['wifi'] ?? 0;
      int mobileBytes = result['mobile'] ?? 0;

      // 🔥 DEBUG (cek apakah data masuk)
      print("wifiBytes: $wifiBytes");
      print("mobileBytes: $mobileBytes");

      await DatabaseHelper.instance.insertOrUpdate(
        todayDate,
        wifiBytes,
        mobileBytes,
      );

      double totalMb = (wifiBytes + mobileBytes) / (1024 * 1024);

      setState(() {
        wifiUsage = _formatBytes(wifiBytes);
        mobileUsage = _formatBytes(mobileBytes);
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
    } else {
      statusUsage = "Aman ✅";
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

  String _totalUsage() {
    double wifi = double.tryParse(wifiUsage.split(" ")[0]) ?? 0;
    double mobile = double.tryParse(mobileUsage.split(" ")[0]) ?? 0;
    return "${(wifi + mobile).toStringAsFixed(2)} MB";
  }

  Future<void> checkLimitAndWarn(int currentUsage) async {
    int limitInBytes = 10 * 1024 * 1024 * 1024;

    if (currentUsage >= limitInBytes) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Batas Kuota Tercapai!"),
          content: const Text(
            "Penggunaan data Anda sudah mencapai limit.",
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
                  builder: (context) => const HistoryPage(),
                ),
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
          colors: [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Izin Diperlukan"),
        content: const Text(
          "Aktifkan izin penggunaan data di pengaturan.",
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
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}