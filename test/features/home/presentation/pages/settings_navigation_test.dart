import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/settings/presentation/pages/settings_with_back_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/home_test_window.dart';

void main() {
  testWidgets('settings opens the redesigned page and back returns home',
      (tester) async {
    usePhoneWindow(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ChatHomePage(today: DateTime(2026, 7, 16)),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNothing);
    final settingsButton = find.byKey(const Key('drawer-profile-button'));
    await tester.tap(settingsButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SettingsWithBackPage), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Settings')).style?.fontSize,
      AppTypography.title,
    );
    expect(
      tester.widget<Text>(find.text('Edit profile')).style?.fontSize,
      AppTypography.body,
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('1 000 000 Ar'), findsOneWidget);
  });
}
