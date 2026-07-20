import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ForegroundNotificationService {
  ForegroundNotificationService(this._notifications, {this.onNotificationTap});

  final FlutterLocalNotificationsPlugin _notifications;

  /// Optional callback when user taps a notification
  final void Function(RemoteMessage message)? onNotificationTap;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  static const _androidChannel = AndroidNotificationChannel(
    'budgets_notifications',
    'Budgets Notifications',
    description: 'Notifications for reminders and budget warnings',
    importance: Importance.high,
  );

  Future<void> init() async {
    // Create the Android notification channel FIRST (required for Android 8+)
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    // Use @drawable/ic_notification for the small icon (white silhouette)
    // Falls back to @mipmap/ic_launcher if not found
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings: settings);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle notification tap when app was in background
    _openedAppSub ??= FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('🔔 [Tap] Notification tapped (app was backgrounded):');
      print('   Title: ${message.notification?.title}');
      print('   Data: ${message.data}');
      onNotificationTap?.call(message);
    });

    // Check if app was opened from a terminated state via notification tap
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('🔔 [Initial] App opened from notification tap (was terminated):');
      print('   Title: ${initialMessage.notification?.title}');
      print('   Data: ${initialMessage.data}');
      onNotificationTap?.call(initialMessage);
    }

    _foregroundSub ??= FirebaseMessaging.onMessage.listen((message) async {
      print('🔔 [Foreground] FCM message received:');
      print('   Message ID: ${message.messageId}');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      print('   Data: ${message.data}');

      final notification = message.notification;
      if (notification == null) return;

      final androidDetails = AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
      );
      const iosDetails = DarwinNotificationDetails();
      final details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _notifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: details,
        payload: message.data.isEmpty ? null : message.data.toString(),
      );
    });
  }

  void dispose() {
    _foregroundSub?.cancel();
    _foregroundSub = null;
    _openedAppSub?.cancel();
    _openedAppSub = null;
  }
}
