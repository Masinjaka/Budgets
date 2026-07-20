import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_ai_entry_repository.dart';

void main() {
  test('inserts a manual entry without reloading the selected date', () async {
    final date = DateTime(2026, 7, 12, 14, 30);
    final repository = FakeAiEntryRepository()
      ..entries = [_entry('Breakfast', date)]
      ..manualEntry = _entry('Coffee', date);
    final viewModel = AiEntryViewModel(repository, date);
    await viewModel.loadDate(date);

    await viewModel.addManualEntry(
      ManualEntryInput(
        title: 'Coffee',
        amount: 3000,
        transactionType: 'expense',
        occurredAt: date,
      ),
    );

    expect(repository.addedManualInput?.occurredAt, date);
    expect(viewModel.entries.map((entry) => entry.title), [
      'Coffee',
      'Breakfast',
    ]);
    expect(repository.dateLoadCount, 1);
  });
}

FinanceEntry _entry(String title, DateTime date) => FinanceEntry(
      id: title,
      title: title,
      categoryName: 'Foods & Drinks',
      amount: title == 'Coffee' ? 3000 : 24000,
      occurredAt: date,
      transactionType: 'expense',
      currencyCode: 'MGA',
      iconKey: 'food',
      emoji: '🍔',
    );
