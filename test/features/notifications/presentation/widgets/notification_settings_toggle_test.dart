import 'dart:async';

import 'package:budgets/features/notifications/presentation/widgets/notification_settings_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toggles immediately without showing a loading indicator',
      (tester) async {
    final result = Completer<bool>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationSettingsToggle(
            title: 'Daily reminders',
            icon: Icons.alarm_outlined,
            value: false,
            onChanged: (_) => result.future,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    result.complete(true);
    await tester.pump();
  });

  testWidgets('rolls back and shows an error toast when saving fails',
      (tester) async {
    final result = Completer<bool>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationSettingsToggle(
            title: 'Budget alerts',
            icon: Icons.warning_amber_outlined,
            value: false,
            onChanged: (_) => result.future,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    result.completeError(Exception('Save failed'));
    await tester.pump();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(
      find.text('Une erreur est survenue. Veuillez réessayer.'),
      findsOneWidget,
    );
  });
}
