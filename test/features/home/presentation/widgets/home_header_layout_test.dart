import 'package:budgets/core/ui/amount_visibility_controller.dart';
import 'package:budgets/core/ui/amount_visibility_scope.dart';
import 'package:budgets/core/ui/app_responsive_scope.dart';
import 'package:budgets/features/home/presentation/widgets/home_header.dart';
import 'package:budgets/features/notifications/presentation/view_models/finance_notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../notifications/support/fake_finance_notification_repository.dart';

void main() {
  testWidgets('fits the header at the app responsive text scale',
      (tester) async {
    final drawerProgress = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 1),
    );
    final visibilityController = AmountVisibilityController();
    final notifications = FinanceNotificationViewModel(
      FakeFinanceNotificationRepository(),
    );
    addTearDown(drawerProgress.dispose);
    addTearDown(visibilityController.dispose);
    addTearDown(notifications.dispose);

    await tester.pumpWidget(
      AmountVisibilityScope(
        controller: visibilityController,
        child: MaterialApp(
          home: AppResponsiveScope(
            child: Scaffold(
              body: HomeHeader(
                drawerProgress: drawerProgress,
                onMenuPressed: () {},
                balance: 1000000,
                currencyCode: 'MGA',
                notificationViewModel: notifications,
                onNotificationsPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(HomeHeader)).height, 48);
  });
}
