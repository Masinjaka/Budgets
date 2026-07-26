import 'package:budgets/core/theme.dart';
import 'package:budgets/features/notifications/presentation/widgets/notification_reminder_time_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the preferred reminder time and handles taps',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
        home: Scaffold(
          body: NotificationReminderTimeTile(
            time: const TimeOfDay(hour: 7, minute: 5),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Preferred reminder time'), findsOneWidget);
    final time = tester.widget<Text>(
      find.byKey(const Key('notification-reminder-time-value')),
    );
    expect(time.data, '07:05');
    expect(time.style?.color, Colors.black);

    await tester.tap(find.text('Preferred reminder time'));
    expect(tapped, isTrue);
  });
}
