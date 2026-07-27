import 'package:budgets/core/legal/legal_document_launcher.dart';
import 'package:budgets/features/auth/presentation/pages/sign_up_page.dart';
import 'package:budgets/features/auth/presentation/widgets/legal_consent_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('requires legal consent before enabling account creation',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignUpPage(legalLauncher: _NoopLegalDocumentLauncher()),
        ),
      ),
    );

    expect(_submitButton(tester).onPressed, isNull);
    expect(find.text('Confirmer le mot de passe'), findsNothing);
    expect(
      tester.getTopLeft(find.byType(LegalConsentCheckbox)).dy,
      greaterThan(tester.getTopLeft(find.text('Mot de passe')).dy),
    );

    await tester.ensureVisible(find.byKey(const Key('legal-consent-checkbox')));
    await tester.tap(find.byKey(const Key('legal-consent-checkbox')));
    await tester.pump();

    expect(_submitButton(tester).onPressed, isNotNull);
  });
}

ElevatedButton _submitButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(find.byType(ElevatedButton));
}

class _NoopLegalDocumentLauncher implements LegalDocumentLauncher {
  const _NoopLegalDocumentLauncher();

  @override
  Future<void> openPrivacyPolicy() async {}

  @override
  Future<void> openTermsAndConditions() async {}
}
