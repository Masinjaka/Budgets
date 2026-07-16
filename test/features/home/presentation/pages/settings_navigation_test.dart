import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:budgets/features/settings/presentation/pages/settings_with_back_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  testWidgets('settings opens the legacy page and back returns home',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: ResponsiveSizer(
          builder: (context, orientation, screenType) => MaterialApp(
            home: ChatHomePage(today: DateTime(2026, 7, 16)),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Settings').hitTestable(), findsOneWidget);
    final settingsButton = find.byKey(const Key('drawer-settings-button'));
    await tester.tap(settingsButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SettingsWithBackPage), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('1 000 000 Ar'), findsOneWidget);
  });
}
