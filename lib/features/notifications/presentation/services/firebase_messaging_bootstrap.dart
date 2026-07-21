import 'package:budgets/features/notifications/presentation/services/firebase_messaging_background_handler.dart';
import 'package:budgets/features/notifications/presentation/services/foreground_notification_service.dart';
import 'package:budgets/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingBootstrap {
  FirebaseMessagingBootstrap._();

  static ForegroundNotificationService? _foregroundService;

  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    if (_foregroundService != null) return;
    final service = ForegroundNotificationService(
      FlutterLocalNotificationsPlugin(),
    );
    _foregroundService = service;
    try {
      await service.init();
    } catch (error, stackTrace) {
      debugPrint('Unable to initialize notification presentation: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
