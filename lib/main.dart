import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:pratikum_limit_kuota_kelompok6/src/features/monitoring/network_page.dart';

void main() {
  // Jalankan MyApp, bukan langsung Network
  runApp(const MyApp()); 
=======
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'main_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
>>>>>>> 28e9879b5e29b3b6cbe4d6edad1a9186846cef46
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Opsional: hilangkan banner debug
      home: Network(), // Network sekarang punya akses ke Directionality dari MaterialApp
=======
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode:
          themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainPage(),
>>>>>>> 28e9879b5e29b3b6cbe4d6edad1a9186846cef46
    );
  }
}