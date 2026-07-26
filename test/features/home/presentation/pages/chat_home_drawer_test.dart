import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/home_test_window.dart';

void main() {
  testWidgets('menu pushes the dashboard aside and can be closed',
      (tester) async {
    usePhoneWindow(tester);
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );

    final homePanel = find.byKey(const Key('home-page-panel'));
    final drawerPanel = find.byKey(const Key('drawer-panel'));
    expect(_homeTranslation(tester, homePanel), 0);
    expect(_horizontalTranslation(tester, drawerPanel), lessThan(-300));
    expect(_menuOpacity(tester), 1);
    expect(_dimming(tester), 0);

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();

    expect(_homeTranslation(tester, homePanel), greaterThan(300));
    expect(_horizontalTranslation(tester, drawerPanel), 0);
    expect(_menuOpacity(tester), 0);
    expect(_dimming(tester), closeTo(0.09, 0.005));
    expect(find.text('Envelope'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Plan'), findsNothing);
    expect(find.text('Feedback'), findsOneWidget);
    expect(find.text('Resume from a specific date'), findsOneWidget);
    expect(find.text('July 2026'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
    expect(find.text('Settings'), findsNothing);
    expect(find.byKey(const Key('drawer-settings-button')), findsNothing);
    expect(find.byKey(const Key('drawer-profile-button')), findsOneWidget);
    expect(find.byKey(const Key('drawer-app-icon')), findsOneWidget);
    expect(find.byKey(const Key('drawer-app-title')), findsOneWidget);
    expect(find.byTooltip('Close menu'), findsNothing);
    final titleY =
        tester.getCenter(find.byKey(const Key('drawer-app-title'))).dy;
    final envelopeY = tester.getCenter(find.text('Envelope')).dy;
    final feedbackY = tester.getCenter(find.text('Feedback')).dy;
    final calendarTitleY =
        tester.getCenter(find.text('Resume from a specific date')).dy;
    expect(feedbackY - envelopeY, greaterThan(80));
    expect(titleY, lessThan(envelopeY));
    expect(feedbackY, lessThan(calendarTitleY));

    await tester.dragFrom(
      const Offset(380, 400),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();

    expect(_homeTranslation(tester, homePanel), 0);
    expect(_horizontalTranslation(tester, drawerPanel), lessThan(-300));
    expect(_menuOpacity(tester), 1);
    expect(_dimming(tester), 0);
  });

  testWidgets('drawer destinations move with vertical scrolling',
      (tester) async {
    usePhoneWindow(tester);
    tester.view.physicalSize = const Size(400, 600);
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    final before = tester.getCenter(find.text('Envelope')).dy;

    await tester.drag(
      find.byKey(const Key('drawer-scroll-view')),
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();

    expect(tester.getCenter(find.text('Envelope')).dy, lessThan(before));
  });

  testWidgets('horizontal drag directly controls and settles both panels',
      (tester) async {
    usePhoneWindow(tester);
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );

    final homePanel = find.byKey(const Key('home-page-panel'));
    final drawerPanel = find.byKey(const Key('drawer-panel'));
    final dragSurface = find.byKey(const Key('home-drag-surface'));
    final gesture = await tester.startGesture(tester.getCenter(dragSurface));

    await gesture.moveBy(const Offset(120, 0));
    await tester.pump();

    expect(_homeTranslation(tester, homePanel), closeTo(120, 1));
    expect(_horizontalTranslation(tester, drawerPanel), closeTo(-260, 1));
    expect(_menuOpacity(tester), closeTo(0.684, 0.01));
    expect(_dimming(tester), closeTo(0.028, 0.005));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_homeTranslation(tester, homePanel), 0);

    await tester.drag(dragSurface, const Offset(220, 0));
    await tester.pumpAndSettle();
    expect(_homeTranslation(tester, homePanel), greaterThan(300));
    expect(_horizontalTranslation(tester, drawerPanel), 0);

    final drawerSurface = find.byKey(const Key('drawer-drag-surface'));
    final drawerGesture = await tester.startGesture(
      tester.getTopLeft(drawerSurface) + const Offset(10, 20),
    );
    await drawerGesture.moveBy(const Offset(-220, 0));
    await tester.pump();

    expect(_homeTranslation(tester, homePanel), closeTo(160, 1));
    expect(_horizontalTranslation(tester, drawerPanel), closeTo(-220, 1));
    expect(_dimming(tester), closeTo(0.038, 0.005));

    await drawerGesture.up();
    await tester.pumpAndSettle();
    expect(_homeTranslation(tester, homePanel), 0);
    expect(_horizontalTranslation(tester, drawerPanel), lessThan(-300));
    expect(_dimming(tester), 0);
  });

  testWidgets('tablet uses a collapsible persistent side panel',
      (tester) async {
    useTabletWindow(tester);
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );

    final sidebar = find.byKey(const Key('persistent-sidebar-container'));
    expect(find.byKey(const Key('persistent-sidebar-layout')), findsOneWidget);
    expect(find.byKey(const Key('home-drag-surface')), findsNothing);
    expect(tester.getSize(sidebar).width, 68);

    await tester.tap(find.byKey(const Key('persistent-sidebar-toggle')));
    await tester.pumpAndSettle();

    expect(tester.getSize(sidebar).width, 320);
    expect(find.text('Resume from a specific date'), findsOneWidget);

    await tester.tap(find.byKey(const Key('collapse-sidebar-button')));
    await tester.pumpAndSettle();

    expect(tester.getSize(sidebar).width, 68);
  });
}

double _horizontalTranslation(WidgetTester tester, Finder finder) {
  return tester.widget<Transform>(finder).transform.getTranslation().x;
}

double _homeTranslation(WidgetTester tester, Finder finder) {
  return tester.getTopLeft(finder).dx;
}

double _menuOpacity(WidgetTester tester) {
  return tester
      .widget<Opacity>(find.byKey(const Key('burger-menu-opacity')))
      .opacity;
}

double _dimming(WidgetTester tester) {
  final color = tester
      .widget<ColoredBox>(find.byKey(const Key('home-dim-overlay')))
      .color;
  return (color.toARGB32() >> 24) / 255;
}
