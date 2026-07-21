import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  testWidgets('returns a manual income for the selected calendar date',
      (tester) async {
    ManualEntryInput? result;
    await tester.pumpWidget(
      ProviderScope(
        child: ResponsiveSizer(
          builder: (_, __, ___) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    result = await ManualEntrySheet.show(
                      context,
                      categories: const [],
                      targetDate: DateTime(2026, 7, 12),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('manual-income-option')));
    await tester.enterText(find.byType(TextFormField).at(0), 'Salary');
    await tester.enterText(find.byType(TextFormField).at(1), '500000');
    await tester.tap(find.byKey(const Key('save-manual-entry-button')));
    await tester.pumpAndSettle();

    expect(result?.title, 'Salary');
    expect(result?.amount, 500000);
    expect(result?.transactionType, 'income');
    expect(result?.occurredAt, isNotNull);
    expect(result?.occurredAt.year, 2026);
    expect(result?.occurredAt.month, 7);
    expect(result?.occurredAt.day, 12);
  });
}
