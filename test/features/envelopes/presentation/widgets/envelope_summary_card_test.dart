import 'package:budgets/features/envelopes/presentation/widgets/envelope_summary_card.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the localized metric-card design', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SizedBox(
            width: 390,
            child: EnvelopeSummaryCard(
              budget: 1000000,
              spent: 250000,
              currencyCode: 'MGA',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Disponible dans les enveloppes'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Dépensé'), findsOneWidget);
    expect(find.byKey(const Key('envelope-available-card')), findsOneWidget);
    expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
