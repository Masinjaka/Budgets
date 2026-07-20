import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/finance_entry_amount_badge.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/finance_entry_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows expenses and incomes in muted status pills',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FinanceEntryItem(entry: _entry('expense', 'expense')),
              FinanceEntryItem(entry: _entry('income', 'income')),
            ],
          ),
        ),
      ),
    );

    final expense = tester.widget<Text>(
      find.byKey(const Key('finance-entry-amount-expense')),
    );
    final income = tester.widget<Text>(
      find.byKey(const Key('finance-entry-amount-income')),
    );

    expect(
      _badgeColor(tester, 'expense'),
      FinanceEntryAmountBadge.expenseBackground,
    );
    expect(
      _badgeColor(tester, 'income'),
      FinanceEntryAmountBadge.incomeBackground,
    );
    expect(expense.style?.color, Colors.black);
    expect(income.style?.color, Colors.black);
    expect(expense.style?.fontSize, 11);
    expect(income.style?.fontSize, 11);
    expect(expense.data, startsWith('-'));
    expect(income.data, startsWith('+'));
  });

  testWidgets('shows transfers in a blue amount pill', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinanceEntryItem(
            entry: _entry('transfer', 'transfer', entryType: 'transfer'),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.swap_vert_rounded), findsOneWidget);
    final amount = tester.widget<Text>(
      find.byKey(const Key('finance-entry-amount-transfer')),
    );
    expect(amount.data, '-5 000 Ar');
    expect(
      _badgeColor(tester, 'transfer'),
      FinanceEntryAmountBadge.transferBackground,
    );
    expect(amount.style?.color, Colors.black);
    expect(amount.style?.fontSize, 11);
  });
}

Color? _badgeColor(WidgetTester tester, String id) {
  final badge = tester.widget<DecoratedBox>(
    find.byKey(Key('finance-entry-amount-badge-$id')),
  );
  return (badge.decoration as BoxDecoration).color;
}

FinanceEntry _entry(
  String id,
  String type, {
  String entryType = 'transaction',
}) =>
    FinanceEntry(
      id: id,
      title: entryType == 'transfer' ? 'Moved from Cash to Bank' : id,
      categoryName: entryType == 'transfer' ? 'Transfer' : 'Other',
      amount: 5000,
      occurredAt: DateTime(2026, 7, 17),
      transactionType: type,
      currencyCode: 'MGA',
      iconKey: entryType == 'transfer' ? 'transfer' : 'other',
      emoji: '🧾',
      entryType: entryType,
    );
