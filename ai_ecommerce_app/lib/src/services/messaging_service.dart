import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  static Future<void> initializeAndRequestPermissions() async {
    final messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    }

    await messaging.setAutoInitEnabled(true);
    await messaging.subscribeToTopic('offers');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages if needed
    });
  }
}