import 'package:budgets/features/plans/presentation/pages/plan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the Free and Drala Plus perk comparison', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlanPage()));

    expect(find.text('Choose what works for you'), findsOneWidget);
    expect(find.text('Free'), findsNWidgets(2));
    expect(find.text('Drala Plus'), findsNWidgets(2));
    expect(find.text('Manual transactions'), findsOneWidget);
    expect(find.text('20/day'), findsOneWidget);
    expect(find.text('Generous monthly fair use'), findsOneWidget);
    expect(find.text('Receipt scanning'), findsOneWidget);
    expect(find.text('AI spending insights'), findsOneWidget);
    expect(find.text('Stay on Free'), findsOneWidget);
  });

  testWidgets('runs checkout callback when Drala Plus is selected',
      (tester) async {
    var subscriptionStarted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PlanPage(
          onSubscribePlus: () async => subscriptionStarted = true,
        ),
      ),
    );

    await tester.tap(find.text('Drala Plus').first);
    await tester.pump();
    expect(find.text('Subscribe to Drala Plus'), findsOneWidget);

    await tester.tap(find.byKey(const Key('plan-continue-button')));
    await tester.pump();

    expect(subscriptionStarted, isTrue);
  });
}
