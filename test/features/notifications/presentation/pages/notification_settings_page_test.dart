import 'package:budgets/features/notifications/domain/models/notification_settings.dart';
import 'package:budgets/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:budgets/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows preferred time only when daily reminders are enabled',
      (tester) async {
    await _pumpPage(
      tester,
      NotificationSettings.defaults().copyWith(remindersEnabled: false),
    );
    expect(find.text('Preferred reminder time'), findsNothing);

    await _pumpPage(
      tester,
      NotificationSettings.defaults(
        timezoneOffsetMinutes: 180,
      ).copyWith(reminderHour: 8, reminderMinute: 30),
    );
    expect(find.text('Preferred reminder time'), findsOneWidget);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  NotificationSettings settings,
) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        notificationControllerProvider.overrideWith(
          () => _FakeNotificationController(settings),
        ),
      ],
      child: const MaterialApp(home: NotificationSettingsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeNotificationController extends NotificationController {
  _FakeNotificationController(this.settings);

  final NotificationSettings settings;

  @override
  Future<NotificationSettings> build() async => settings;
}
