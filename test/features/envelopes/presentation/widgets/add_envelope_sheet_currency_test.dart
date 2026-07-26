import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/envelopes/domain/models/envelope_category.dart';
import 'package:budgets/features/envelopes/presentation/widgets/add_envelope_sheet.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('stores a selected-currency envelope amount as MGA',
      (tester) async {
    int? savedAmount;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AddEnvelopeSheet.show(
                context,
                categories: const [_food],
                month: DateTime(2026, 7),
                currencyState: _usd,
                onSave: (_, __, amount) async => savedAmount = amount,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text(r'$0'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Food budget');
    await tester.enterText(find.byType(TextFormField).at(1), '200');
    await tester.tap(find.byKey(const Key('manual-category-food')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-envelope-button')));
    await tester.pumpAndSettle();

    expect(savedAmount, 1000000);
  });
}

const _food = EnvelopeCategory(
  id: 'food',
  name: 'Food',
  emoji: '🍔',
  color: 'FF888888',
);

const _usd = CurrencyState(
  code: 'USD',
  baseCode: 'MGA',
  rates: {'USD': 0.0002},
);
