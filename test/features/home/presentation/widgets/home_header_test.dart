import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/amount_visibility_controller.dart';
import 'package:budgets/core/ui/amount_visibility_scope.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/home/presentation/widgets/home_header.dart';
import 'package:budgets/features/notifications/presentation/view_models/finance_notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../notifications/support/fake_finance_notification_repository.dart';

void main() {
  testWidgets('toggles balance privacy and has no subtitle', (tester) async {
    final drawerProgress = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 1),
    );
    final visibilityController = AmountVisibilityController();
    final collapseProgress = ValueNotifier<double>(0);
    final notifications = FinanceNotificationViewModel(
      FakeFinanceNotificationRepository(),
    );
    addTearDown(drawerProgress.dispose);
    addTearDown(visibilityController.dispose);
    addTearDown(collapseProgress.dispose);
    addTearDown(notifications.dispose);

    await tester.pumpWidget(
      AmountVisibilityScope(
        controller: visibilityController,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: HomeHeader(
              drawerProgress: drawerProgress,
              collapseProgress: collapseProgress,
              onMenuPressed: () {},
              balance: 1000000,
              currencyCode: 'MGA',
              notificationViewModel: notifications,
              onNotificationsPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('1 000 000 Ar'), findsOneWidget);
    expect(find.text('Wallet balance left'), findsOneWidget);
    final overallBalance = tester.widget<Text>(
      find.text('Wallet balance left'),
    );
    expect(overallBalance.style?.fontSize, AppTypography.caption);
    expect(overallBalance.style?.color, Colors.black);
    expect(find.text('All time'), findsNothing);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    final balanceText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('header-balance-label')),
        matching: find.byType(Text),
      ),
    );
    expect(balanceText.style?.fontWeight, FontWeight.w800);

    collapseProgress.value = 1;
    await tester.pump();
    final compactLabel = tester.widget<Text>(find.text('Wallet balance left'));
    expect(compactLabel.style?.color, const Color(0xFF606060));

    await tester.tap(find.byKey(const Key('balance-visibility-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('1 000 000 Ar'), findsOneWidget);
    expect(find.text('***'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('1 000 000 Ar'), findsNothing);
    expect(find.text('***'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byKey(const Key('balance-visibility-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('1 000 000 Ar'), findsOneWidget);
  });
}
