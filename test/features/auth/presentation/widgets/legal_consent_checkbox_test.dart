import 'package:budgets/core/legal/legal_document_launcher.dart';
import 'package:budgets/features/auth/presentation/widgets/legal_consent_checkbox.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('changes consent and opens both legal documents', (tester) async {
    final launcher = _FakeLegalDocumentLauncher();
    bool accepted = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LegalConsentCheckbox(
            value: false,
            launcher: launcher,
            onChanged: (value) => accepted = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('legal-consent-checkbox')));
    expect(accepted, isTrue);

    await tester.tap(find.byKey(const Key('terms-and-conditions-link')));
    await tester.pump();
    expect(launcher.termsOpenCount, 1);

    await tester.tap(find.byKey(const Key('privacy-policy-link')));
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
