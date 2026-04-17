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

  final int limitBytes = 1024 * 1024 * 1024;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchUsage();

    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
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
      });

      checkLimitAndWarn(wifiBytes + mobileBytes);
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        _showPermissionDialog();
      }
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

  double _getTotalMB() {
    double wifi = double.tryParse(wifiUsage.split(" ")[0]) ?? 0;
    double mobile = double.tryParse(mobileUsage.split(" ")[0]) ?? 0;
    return wifi + mobile;
  }

  double _getPercentage() {
    double totalMB = _getTotalMB();
    double limitMB = 1024;
    return (totalMB / limitMB).clamp(0, 1);
  }

  String _statusText() {
    double percent = _getPercentage();
    if (percent >= 1) return "Habis";
    if (percent >= 0.8) return "Hampir Habis";
    return "Aman";
  }

  Color _statusColor() {
    double percent = _getPercentage();
    if (percent >= 1) return Colors.red;
    if (percent >= 0.8) return Colors.orange;
    return Colors.green;
  }

  Future<void> checkLimitAndWarn(int currentUsage) async {
    if (currentUsage >= limitBytes) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Batas Kuota Tercapai!"),
          content: const Text(
            "Kuota kamu sudah habis. Aktifkan data limit di pengaturan.",
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
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _animatedHistoryButton(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchUsage,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _totalCard(),
            const SizedBox(height: 20),
            _usageCard("WiFi", wifiUsage, Icons.wifi),
            const SizedBox(height: 20),
            _usageCard("Mobile", mobileUsage, Icons.signal_cellular_alt),
          ],
        ),
      ),
    );
  }

  Widget _totalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text("Total Hari Ini", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text(
            "${_getTotalMB().toStringAsFixed(2)} MB",
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: _getPercentage(), minHeight: 10),
          const SizedBox(height: 10),
          Text(
            "Status: ${_statusText()}",
            style: TextStyle(
              color: _statusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _usageCard(String title, String value, IconData icon) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        _showDetail(title, value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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

  Widget _animatedHistoryButton() {
    return StatefulBuilder(
      builder: (context, setStateBtn) {
        double scale = 1;

        return GestureDetector(
          onTapDown: (_) => setStateBtn(() => scale = 0.85),
          onTapUp: (_) {
            setStateBtn(() => scale = 1);

            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (_, __, ___) => const HistoryPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 150),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history, color: Colors.white),
            ),
          ),
        );
      },
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