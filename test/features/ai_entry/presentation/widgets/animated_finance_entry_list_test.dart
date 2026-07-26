import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/animated_finance_entry_list.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/finance_entry_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps breathing room between transaction rows', (tester) async {
    await tester.pumpWidget(
      _app([_entry('first', 'Breakfast'), _entry('second', 'Lunch')]),
    );

    final first = find.byKey(const ValueKey('finance-entry-first'));
    final second = find.byKey(const ValueKey('finance-entry-second'));
    final distance = tester.getTopLeft(second).dy - tester.getTopLeft(first).dy;

    expect(distance, FinanceEntryItem.height);
  });

  testWidgets('inserts a new entry above existing rows with animation',
      (tester) async {
    final existing = _entry('existing', 'Breakfast');
    await tester.pumpWidget(_app([existing]));

    final existingFinder = find.byKey(
      const ValueKey('finance-entry-existing'),
    );
    final initialY = tester.getTopLeft(existingFinder).dy;

    await tester.pumpWidget(
      _app([_entry('new', 'Lunch'), existing]),
    );
    await tester.pump(const Duration(milliseconds: 140));

    final newFinder = find.byKey(const ValueKey('finance-entry-new'));
    expect(newFinder, findsOneWidget);
    expect(existingFinder, findsOneWidget);
    expect(tester.getTopLeft(existingFinder).dy, greaterThan(initialY));
    expect(
      tester.getTopLeft(newFinder).dy,
      lessThan(tester.getTopLeft(existingFinder).dy),
    );

    await tester.pumpAndSettle();
  });

  testWidgets('only non-transfer entries invoke the edit callback',
      (tester) async {
    FinanceEntry? tapped;
    final expense = _entry('expense', 'Lunch');
    final transfer = FinanceEntry(
      id: 'transfer',
      title: 'Moved from Cash to Bank',
      categoryName: 'Transfer',
      amount: 5000,
      occurredAt: DateTime(2026, 7, 17),
      transactionType: 'transfer',
      currencyCode: 'MGA',
      iconKey: 'transfer',
      emoji: '🔄',
      entryType: 'transfer',
    );
    await tester.pumpWidget(_app(
      [expense, transfer],
      onEntryTap: (entry) => tapped = entry,
    ));

    await tester.tap(find.byKey(const ValueKey('finance-entry-expense')));
    expect(tapped, same(expense));

    tapped = null;
    await tester.tap(find.byKey(const ValueKey('finance-entry-transfer')));
    expect(tapped, isNull);
  });
}

Widget _app(
  List<FinanceEntry> entries, {
  ValueChanged<FinanceEntry>? onEntryTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          AnimatedFinanceEntryList(
            entries: entries,
            onEntryTap: onEntryTap,
          ),
        ],
      ),
    ),
  );
}

FinanceEntry _entry(String id, String title) => FinanceEntry(
      id: id,
      title: title,
      categoryName: 'Foods & Drinks',
      amount: 24000,
      occurredAt: DateTime(2026, 7, 17),
      transactionType: 'expense',
      currencyCode: 'MGA',
      iconKey: 'food',
      emoji: '🍔',
    );
