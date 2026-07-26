import 'package:budgets/core/theme.dart';
import 'package:budgets/features/home/presentation/widgets/home_collapsing_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('transitions from the expanded hero to the compact surface',
      (tester) async {
    final progress = ValueNotifier<double>(0);
    addTearDown(progress.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: HomeCollapsingSurface(
            collapseProgress: progress,
            header: const SizedBox(height: 48),
            body: const SizedBox.expand(),
          ),
        ),
      ),
    );

    expect(_background(tester), AppTheme.neutralSurface);
    expect(_radius(tester), HomeCollapsingSurface.expandedRadius);
    expect(_gap(tester), HomeCollapsingSurface.expandedGap);
    expect(
      _headerPadding(tester),
      HomeCollapsingSurface.expandedHeaderPadding,
    );

    progress.value = 0.5;
    await tester.pump();
    expect(
      _background(tester),
      Color.lerp(
        AppTheme.neutralSurface,
        HomeCollapsingSurface.backgroundColor,
        0.5,
      ),
    );
    expect(_radius(tester), HomeCollapsingSurface.expandedRadius / 2);

    progress.value = 1;
    await tester.pump();
    expect(_background(tester), HomeCollapsingSurface.backgroundColor);
    expect(_radius(tester), 0);
    expect(_gap(tester), 0);
    expect(_headerPadding(tester), 0);
  });

  testWidgets('uses the existing dark theme surfaces', (tester) async {
    final progress = ValueNotifier<double>(0);
    addTearDown(progress.dispose);
    await tester.pumpWidget(
      MaterialApp(
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: HomeCollapsingSurface(
          collapseProgress: progress,
          header: const SizedBox(height: 48),
          body: const SizedBox.expand(),
        ),
      ),
    );

    expect(_background(tester), AppTheme.secondaryDark);
    progress.value = 1;
    await tester.pump();
    expect(_background(tester), AppTheme.backgroundDark);
  });
}

Color _background(WidgetTester tester) {
  return tester
      .widget<ColoredBox>(
        find.byKey(const Key('home-collapsing-background')),
      )
      .color;
}

double _radius(WidgetTester tester) {
  final surface = tester.widget<DecoratedBox>(
    find.byKey(const Key('home-content-surface')),
  );
  final decoration = surface.decoration as BoxDecoration;
  return (decoration.borderRadius! as BorderRadius).topLeft.x;
}

double _gap(WidgetTester tester) {
  return tester
      .getSize(find.byKey(const Key('home-header-collapse-gap')))
      .height;
}

double _headerPadding(WidgetTester tester) {
  final padding = tester.widget<Padding>(
    find.byKey(const Key('home-header-vertical-padding')),
  );
  return (padding.padding as EdgeInsets).top;
}
