import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io';

class IntentHelper {
  static Future<void> openUsageAccessSettings() async {
  if (Platform.isAndroid) {
    const intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );

    try {
      await intent.launch();
    } catch (e) {
      print("Gagal membuka usage access: $e");

      const fallbackIntent = AndroidIntent(
        action: 'android.settings.SETTINGS',
      );

      await fallbackIntent.launch();
    }
  }
}

  static void openDataLimitSettings() {}
}