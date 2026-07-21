import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPermissionService {
  NotificationPermissionService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<bool> isGranted() async {
    final settings = await _messaging.getNotificationSettings();
    return isGrantedStatus(settings.authorizationStatus);
  }

  Future<bool> request() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return isGrantedStatus(settings.authorizationStatus);
  }

  static bool isGrantedStatus(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }
}
