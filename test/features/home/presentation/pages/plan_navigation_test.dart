import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:budgets/features/plans/presentation/pages/plan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/home_test_window.dart';

void main() {
  testWidgets('Plan drawer menu opens the plan comparison page',
      (tester) async {
    usePhoneWindow(tester);
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-plan-button')));
    await tester.pumpAndSettle();

    expect(find.byType(PlanPage), findsOneWidget);
    expect(find.text('Choose what works for you'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
  });
}
