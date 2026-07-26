import 'package:budgets/core/legal/legal_document_launcher.dart';
import 'package:budgets/features/settings/presentation/pages/setting_page.dart';
import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens the hosted terms and privacy policy', (tester) async {
    final launcher = _FakeLegalDocumentLauncher();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [userModelProvider.overrideWith((_) async => null)],
        child: MaterialApp(home: SettingPage(legalLauncher: launcher)),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Terms of service'));
    await tester.tap(find.text('Terms of service'));
    await tester.pump();
    expect(launcher.termsOpenCount, 1);

    await tester.ensureVisible(find.text('Privacy policy'));
    await tester.tap(find.text('Privacy policy'));
    await tester.pump();
    expect(launcher.privacyOpenCount, 1);
  });
}

class _FakeLegalDocumentLauncher implements LegalDocumentLauncher {
  int privacyOpenCount = 0;
  int termsOpenCount = 0;

  @override
  Future<void> openPrivacyPolicy() async => privacyOpenCount++;

  @override
  Future<void> openTermsAndConditions() async => termsOpenCount++;
}
