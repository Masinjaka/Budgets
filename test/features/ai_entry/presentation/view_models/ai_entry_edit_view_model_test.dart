import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_ai_entry_repository.dart';

void main() {
  test('updates an entry in place and refreshes balances', () async {
    final repository = FakeAiEntryRepository()
      ..entries = [_entry]
      ..totalFundsValue = 88000;
    final viewModel = AiEntryViewModel(repository, _date);
    await viewModel.loadDate(_date);

    final input = ManualEntryInput(
      title: 'Updated lunch',
      amount: 12000,
      transactionType: 'expense',
      occurredAt: _date,
      categoryId: 'food',
    );
    await viewModel.updateFinanceEntry('entry', input);

    expect(repository.updatedEntryId, 'entry');
    expect(repository.updatedManualInput, same(input));
    expect(viewModel.entries, hasLength(1));
    expect(viewModel.entries.single.title, 'Updated lunch');
    expect(viewModel.totalWalletBalance, 88000);
  });

  test('deletes an entry and refreshes balances', () async {
    final repository = FakeAiEntryRepository()
      ..entries = [_entry]
      ..totalFundsValue = 100000;
    final viewModel = AiEntryViewModel(repository, _date);
    await viewModel.loadDate(_date);

    await viewModel.deleteFinanceEntry('entry');

    expect(repository.deletedEntryId, 'entry');
    expect(viewModel.entries, isEmpty);
    expect(viewModel.totalWalletBalance, 100000);
  });
}

final _date = DateTime(2026, 7, 20);

final _entry = FinanceEntry(
  id: 'entry',
  title: 'Lunch',
  categoryName: 'Food',
  amount: 10000,
  occurredAt: _date,
  transactionType: 'expense',
  currencyCode: 'MGA',
  iconKey: 'food',
  emoji: '🍔',
  categoryId: 'food',
);
