import 'package:budgets/features/settings/presentation/pages/legal_settings_page.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders terms content in French', (tester) async {
    await tester.pumpWidget(_app(const LegalSettingsPage.terms()));

    expect(find.text('Conditions d’utilisation'), findsOneWidget);
    expect(
      find.text('Ces conditions expliquent les règles d’utilisation de Drala.'),
      findsOneWidget,
    );
    expect(find.text('Dernière mise à jour : 21 juillet 2026'), findsOneWidget);
  });

  testWidgets('renders privacy content in French', (tester) async {
    await tester.pumpWidget(_app(const LegalSettingsPage.privacy()));

    expect(find.text('Politique de confidentialité'), findsOneWidget);
    expect(find.text('Vos informations financières vous appartiennent.'),
        findsOneWidget);
  });
}

Widget _app(Widget page) => MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: page,
    );
