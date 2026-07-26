import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/daily_entry_header.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/daily_entry_section.dart';
import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pins bold date and entry count while transactions scroll',
      (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SizedBox(
            height: 300,
            child: DailyEntrySection(
              dateLabel: 'Today, 20 July',
              entries: List.generate(12, _entry),
              isLoading: false,
              controller: controller,
            ),
          ),
        ),
      ),
    );

    final header = find.byKey(const Key('daily-entry-pinned-header'));
    final date = tester.widget<Text>(
      find.byKey(const Key('daily-entry-date-label')),
    );
    final summary = tester.widget<Text>(
      find.byKey(const Key('daily-entry-summary-label')),
    );
    final initialY = tester.getTopLeft(header).dy;
    expect(initialY, 20);
    expect(
      tester.widget<DecoratedBox>(header).decoration,
      isA<BoxDecoration>().having(
        (decoration) => decoration.color,
        'color',
        Colors.transparent,
      ),
    );
    expect(date.style?.fontWeight, FontWeight.w800);
    expect(summary.style?.fontWeight, FontWeight.w800);

    controller.jumpTo(10);
    await tester.pump();
    expect(
      tester.widget<DecoratedBox>(header).decoration,
      isA<BoxDecoration>().having(
        (decoration) => decoration.color,
        'color before pinning',
        Colors.transparent,
      ),
    );

    controller.jumpTo(220);
    await tester.pump();
    final pinnedY = tester.getTopLeft(header).dy;
    expect(pinnedY, lessThan(initialY));
    expect(
      tester.widget<DecoratedBox>(header).decoration,
      isA<BoxDecoration>().having(
        (decoration) => decoration.color,
        'pinned surface color',
        DailyEntryHeader.surfaceColor,
      ),
    );

    await tester.drag(
      find.byKey(const Key('transaction-scroll-view')),
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(header).dy, pinnedY);
  });
}

FinanceEntry _entry(int index) => FinanceEntry(
      id: '$index',
      title: 'Transaction $index',
      categoryName: 'Food',
      amount: 1000,
      occurredAt: DateTime(2026, 7, 20),
      transactionType: 'expense',
      currencyCode: 'MGA',
      iconKey: 'food',
      emoji: '🍔',
    );
