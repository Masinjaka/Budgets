import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/finance_entry_item.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the envelope that funded an expense', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FinanceEntryItem(
            entry: FinanceEntry.fromJson({
              'id': 'groceries',
              'title': 'Groceries',
              'amount': 30000,
              'date': '2026-07-25T10:00:00Z',
              'transaction_type': 'expense',
              'currency_code': 'MGA',
              'envelope_amount_used': 30000,
              'envelope_name': 'Food',
              'category': {
                'name': 'Food',
                'emoji': '🛒',
                'icon_key': 'food',
              },
            }),
          ),
        ),
      ),
    );

    expect(find.text('Taken from envelope Food'), findsNothing);
    expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(
      find.byKey(const Key('finance-entry-envelope-groceries')),
    );
    expect(tooltip.message, 'Taken from envelope Food');
  });

  test('does not expose an envelope that paid nothing', () {
    final entry = FinanceEntry.fromJson({
      'id': 'expense',
      'title': 'Expense',
      'amount': 30000,
      'date': '2026-07-25T10:00:00Z',
      'transaction_type': 'expense',
      'currency_code': 'MGA',
      'envelope_amount_used': 0,
      'envelope_name': 'Food',
    });

    expect(entry.envelopeName, isNull);
  });

  test('reads the envelope relation returned by Supabase', () {
    final entry = FinanceEntry.fromJson({
      'id': 'expense',
      'title': 'Expense',
      'amount': 30000,
      'date': '2026-07-25T10:00:00Z',
      'transaction_type': 'expense',
      'currency_code': 'MGA',
      'envelope_amount_used': 30000,
      'envelope': {'name': 'Food'},
    });

    expect(entry.envelopeName, 'Food');
  });
}
