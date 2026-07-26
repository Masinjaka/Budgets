import 'package:budgets/features/settings/presentation/widgets/settings_content.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the wireframe sections and invokes every destination',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final taps = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsContent(
            profileHeader: const Text('John Doe'),
            onEditProfile: () => taps.add('profile'),
            onChangePassword: () => taps.add('password'),
            onNotifications: () => taps.add('notifications'),
            onCurrency: () => taps.add('currency'),
            onDefaultWallet: () => taps.add('wallet'),
            onTheme: () => taps.add('theme'),
            onLanguage: () => taps.add('language'),
            onScannedReceipts: () => taps.add('receipts'),
            onTerms: () => taps.add('terms'),
            onPrivacy: () => taps.add('privacy'),
            onLogout: () => taps.add('logout'),
            isLoggingOut: false,
          ),
        ),
      ),
    );

    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Legal'), findsOneWidget);
    expect(find.text('Zone de danger'), findsNothing);
    final leadingIcons = tester
        .widgetList<Icon>(
          find.descendant(
            of: find.byType(SettingsMenuItem),
            matching: find.byType(Icon),
          ),
        )
        .where((icon) => icon.icon != Icons.chevron_right_rounded)
        .map((icon) => icon.icon)
        .toList();
    expect(leadingIcons, hasLength(10));
    expect(leadingIcons.toSet(), hasLength(10));

    for (final label in [
      'Edit profile',
      'Change password',
      'Notification',
      'Currency',
      'Set default wallet',
      'Theme',
      'Language',
      'Scanned receipts',
      'Terms of service',
      'Privacy policy',
      'Log out',
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
    }

    expect(
      taps,
      [
        'profile',
        'password',
        'notifications',
        'currency',
        'wallet',
        'theme',
        'language',
        'receipts',
        'terms',
        'privacy',
        'logout',
      ],
    );
  });
}
