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

  Timer? timer;

  String statusUsage = "Aman";
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    fetchUsage();

    timer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchUsage();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchUsage() async {
    try {
      final result = await platform.invokeMethod('getTodayUsage');

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
        _updateStatus((wifiBytes + mobileBytes) / (1024 * 1024));
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

    if (mb >= 1024) {
      return "${(mb / 1024).toStringAsFixed(2)} GB";
    }

    return "${mb.toStringAsFixed(2)} MB";
  }

  double _getTotalMB() {
    double wifi = double.tryParse(wifiUsage.split(" ")[0]) ?? 0;
    double mobile = double.tryParse(mobileUsage.split(" ")[0]) ?? 0;
    return wifi + mobile;
  }

  String _totalUsage() {
    return _getTotalMB().toStringAsFixed(2);
  }

  double _getPercentage() {
    double totalMB = _getTotalMB();
    double limitMB = 1024;
    return (totalMB / limitMB).clamp(0, 1);
  }

  Future<void> checkLimitAndWarn(int currentUsage) async {
    int limitInBytes = 10 * 1024 * 1024 * 1024;

    if (currentUsage >= limitInBytes) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Batas Kuota Tercapai!"),
          content: const Text("Kuota kamu sudah habis."),
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
              child: const Text("Pengaturan"),
            ),
          ],
        ),
      );
    }
  }

  void _showDetail(String title, String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$title Detail"),
        content: Text("Penggunaan hari ini: $value"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Monitoring Data'),
        centerTitle: true,
        backgroundColor: Colors.black,
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
      body: RefreshIndicator(
        onRefresh: fetchUsage,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Total Hari Ini: ${_totalUsage()} MB",
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
              value: _getPercentage(),
              minHeight: 10,
            ),
            const SizedBox(height: 20),
            _usageCard("WiFi Today", wifiUsage, Icons.wifi),
            const SizedBox(height: 20),
            _usageCard("Mobile Today", mobileUsage, Icons.signal_cellular_alt),
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
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showDetail(title, value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Izin Diperlukan"),
        content: const Text("Aktifkan akses usage di pengaturan."),
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
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }
}