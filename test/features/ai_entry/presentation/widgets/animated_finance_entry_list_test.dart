import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/animated_finance_entry_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}

Widget _app(List<FinanceEntry> entries) {
  return MaterialApp(
    home: Scaffold(
      body: CustomScrollView(
        slivers: [AnimatedFinanceEntryList(entries: entries)],
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
