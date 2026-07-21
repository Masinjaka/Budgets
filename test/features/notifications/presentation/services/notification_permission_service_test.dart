import 'package:budgets/features/notifications/presentation/services/notification_permission_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationPermissionService.isGrantedStatus', () {
    test('accepts full and provisional authorization', () {
      expect(
        NotificationPermissionService.isGrantedStatus(
          AuthorizationStatus.authorized,
        ),
        isTrue,
      );
      expect(
        NotificationPermissionService.isGrantedStatus(
          AuthorizationStatus.provisional,
        ),
        isTrue,
      );
    });

    test('rejects denied and undetermined authorization', () {
      expect(
        NotificationPermissionService.isGrantedStatus(
          AuthorizationStatus.denied,
        ),
        isFalse,
      );
      expect(
        NotificationPermissionService.isGrantedStatus(
          AuthorizationStatus.notDetermined,
        ),
        isFalse,
      );
    });
  });
}
