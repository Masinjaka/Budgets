import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('menu pushes the dashboard aside and can be closed',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );

    final homePanel = find.byKey(const Key('home-page-panel'));
    final drawerPanel = find.byKey(const Key('drawer-panel'));
    expect(_horizontalTranslation(tester, homePanel), 0);
    expect(_horizontalTranslation(tester, drawerPanel), lessThan(-300));
    expect(_menuOpacity(tester), 1);

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();

    expect(_horizontalTranslation(tester, homePanel), greaterThan(300));
    expect(_horizontalTranslation(tester, drawerPanel), 0);
    expect(_menuOpacity(tester), 0);
    expect(find.text('Envelope'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Resume from a specific date'), findsOneWidget);
    expect(find.text('July'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.byTooltip('Close menu'));
    await tester.pumpAndSettle();

    expect(_horizontalTranslation(tester, homePanel), 0);
    expect(_horizontalTranslation(tester, drawerPanel), lessThan(-300));
    expect(_menuOpacity(tester), 1);
  });

  testWidgets('horizontal drag directly controls and settles both panels',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );

    final homePanel = find.byKey(const Key('home-page-panel'));
    final drawerPanel = find.byKey(const Key('drawer-panel'));
    final dragSurface = find.byKey(const Key('home-drag-surface'));
    final gesture = await tester.startGesture(tester.getCenter(dragSurface));

    await gesture.moveBy(const Offset(120, 0));
    await tester.pump();

    expect(_horizontalTranslation(tester, homePanel), closeTo(120, 1));
    expect(_horizontalTranslation(tester, drawerPanel), closeTo(-240, 1));
    expect(_menuOpacity(tester), closeTo(2 / 3, 0.01));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_horizontalTranslation(tester, homePanel), 0);

    await tester.drag(dragSurface, const Offset(220, 0));
    await tester.pumpAndSettle();
    expect(_horizontalTranslation(tester, homePanel), greaterThan(300));
    expect(_horizontalTranslation(tester, drawerPanel), 0);

    final drawerSurface = find.byKey(const Key('drawer-drag-surface'));
    final drawerGesture = await tester.startGesture(
      tester.getTopLeft(drawerSurface) + const Offset(100, 100),
    );
    await drawerGesture.moveBy(const Offset(-220, 0));
    await tester.pump();

    expect(_horizontalTranslation(tester, homePanel), closeTo(140, 1));
    expect(_horizontalTranslation(tester, drawerPanel), closeTo(-220, 1));

    await drawerGesture.up();
    await tester.pumpAndSettle();
    expect(_horizontalTranslation(tester, homePanel), 0);
    expect(_horizontalTranslation(tester, drawerPanel), lessThan(-300));
  });
}

double _horizontalTranslation(WidgetTester tester, Finder finder) {
  return tester.widget<Transform>(finder).transform.getTranslation().x;
}

double _menuOpacity(WidgetTester tester) {
  return tester
      .widget<Opacity>(find.byKey(const Key('burger-menu-opacity')))
      .opacity;
}
