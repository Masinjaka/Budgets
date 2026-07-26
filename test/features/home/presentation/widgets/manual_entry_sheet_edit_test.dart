import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/home/domain/models/manual_entry_sheet_result.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('prefills and returns edits for an existing transaction',
      (tester) async {
    ManualEntrySheetResult? result;
    await tester.pumpWidget(_app((context) async {
      result = await ManualEntrySheet.show(
        context,
        categories: Future.value(const [_food]),
        targetDate: _entry.occurredAt,
        entry: _entry,
      );
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Edit entry'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('12 000'), findsOneWidget);
    expect(find.text('With a friend'), findsOneWidget);
    expect(find.byKey(const Key('delete-manual-entry-button')), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Team lunch');
    await tester.ensureVisible(
      find.byKey(const Key('save-manual-entry-button')),
    );
    await tester.tap(find.byKey(const Key('save-manual-entry-button')));
    await tester.pumpAndSettle();

    expect(result?.action, ManualEntrySheetAction.save);
    expect(result?.input?.title, 'Team lunch');
    expect(result?.input?.categoryId, 'food');
    expect(result?.input?.sourceWalletId, 'cash');
    expect(result?.input?.occurredAt, _entry.occurredAt);
  });

  testWidgets('returns a delete action from edit mode', (tester) async {
    ManualEntrySheetResult? result;
    await tester.pumpWidget(_app((context) async {
      result = await ManualEntrySheet.show(
        context,
        categories: Future.value(const [_food]),
        targetDate: _entry.occurredAt,
        entry: _entry,
      );
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('delete-manual-entry-button')),
    );
    await tester.tap(find.byKey(const Key('delete-manual-entry-button')));
    await tester.pumpAndSettle();

    expect(result?.action, ManualEntrySheetAction.delete);
    expect(result?.input, isNull);
  });

  testWidgets('edits in selected currency and returns MGA storage amount',
      (tester) async {
    ManualEntrySheetResult? result;
    await tester.pumpWidget(_app((context) async {
      result = await ManualEntrySheet.show(
        context,
        categories: Future.value(const [_food]),
        targetDate: _entry.occurredAt,
        currencyState: _usd,
        entry: _entry,
      );
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('2.4'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), '200');
    await tester.ensureVisible(
      find.byKey(const Key('save-manual-entry-button')),
    );
    await tester.tap(find.byKey(const Key('save-manual-entry-button')));
    await tester.pumpAndSettle();

    expect(result?.input?.amount, 1000000);
  });
}

Widget _app(Future<void> Function(BuildContext context) open) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => open(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

const _food = ManualEntryCategory(
  id: 'food',
  name: 'Food',
  emoji: '🍔',
  transactionType: 'expense',
);

final _entry = FinanceEntry(
  id: 'entry',
  title: 'Lunch',
  description: 'With a friend',
  categoryName: 'Food',
  categoryId: 'food',
  amount: 12000,
  occurredAt: DateTime(2026, 7, 20, 12, 30),
  transactionType: 'expense',
  currencyCode: 'MGA',
  iconKey: 'food',
  emoji: '🍔',
  sourceWalletId: 'cash',
);

const _usd = CurrencyState(
  code: 'USD',
  baseCode: 'MGA',
  rates: {'USD': 0.0002},
);
