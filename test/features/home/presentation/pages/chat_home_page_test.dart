import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/home_test_window.dart';

void main() {
  testWidgets('shows the hard-coded dashboard and accepts chat input',
      (tester) async {
    usePhoneWindow(tester);
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );
    await tester.pumpAndSettle();

    final background = find.byKey(const Key('home-collapsing-background'));
    expect(tester.getTopLeft(background).dx, 0);
    expect(tester.getSize(background).width, 400);
    expect(find.text('1 000 000 Ar'), findsOneWidget);
    expect(find.text('All time'), findsNothing);
    expect(find.text('Today, 16 July'), findsOneWidget);
    expect(find.text('3 expenses'), findsOneWidget);
    expect(find.text('Burgers & Fries'), findsOneWidget);
    expect(find.text('Gift'), findsOneWidget);
    expect(find.text('Alcohol'), findsOneWidget);
    expect(find.text('-\$ 3.99'), findsNWidgets(3));
    expect(
      find.text(
        'You have 20 AI requests remaining today',
        findRichText: true,
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'Lunch 12 dollars');

    expect(find.text('Lunch 12 dollars'), findsOneWidget);
  });

  testWidgets('selected calendar date updates the dashboard period',
      (tester) async {
    usePhoneWindow(tester);
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    expect(find.text('Wednesday, 15 July'), findsOneWidget);
  });

  testWidgets('wide phones keep the home surface edge-to-edge', (tester) async {
    useWidePhoneWindow(tester);
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );
    await tester.pumpAndSettle();

    final background = find.byKey(const Key('home-collapsing-background'));
    expect(tester.getTopLeft(background).dx, 0);
    expect(tester.getSize(background).width, 484);
  });
}
