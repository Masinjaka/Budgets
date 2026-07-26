import 'package:budgets/features/notifications/domain/models/finance_notification.dart';
import 'package:budgets/features/notifications/presentation/view_models/finance_notification_view_model.dart';
import 'package:budgets/features/notifications/presentation/widgets/notification_inbox_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_finance_notification_repository.dart';

void main() {
  testWidgets('shows the warning badge while notifications are unread',
      (tester) async {
    var pressed = false;
    final viewModel = FinanceNotificationViewModel(
      FakeFinanceNotificationRepository([_notification]),
    );
    addTearDown(viewModel.dispose);
    await viewModel.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationInboxButton(
            viewModel: viewModel,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('notification-warning-badge')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('notification-inbox-button')));
    expect(pressed, isTrue);
  });
}

final _notification = FinanceNotification(
  id: 'warning',
  envelopeId: 'food',
  envelopeName: 'Food',
  amount: 25000,
  periodMonth: DateTime(2026, 7),
  isRead: false,
  createdAt: DateTime(2026, 7, 26),
);
