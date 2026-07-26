import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/finance_entry_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays an entry in the selected currency', (tester) async {
    const currency = CurrencyState(
      code: 'EUR',
      baseCode: 'MGA',
      rates: {'EUR': 0.0002},
    );
    final entry = FinanceEntry(
      id: 'coffee',
      title: 'Coffee',
      categoryName: 'Food',
      amount: 5000,
      occurredAt: DateTime(2026, 7, 25),
      transactionType: 'expense',
      currencyCode: 'MGA',
      iconKey: 'food',
      emoji: '☕',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinanceEntryItem(
            entry: entry,
            currencyState: currency,
          ),
        ),
      ),
    );

    expect(find.text('-€1'), findsOneWidget);
    expect(find.text('-5 000 Ar'), findsNothing);
  });
}
