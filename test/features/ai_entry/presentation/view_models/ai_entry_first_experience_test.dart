import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_ai_entry_repository.dart';

void main() {
  test('identifies a new account with no entry history', () async {
    final repository = FakeAiEntryRepository();
    final viewModel = AiEntryViewModel(repository, DateTime(2026, 7, 28));
    addTearDown(viewModel.dispose);

    await viewModel.loadDate(DateTime(2026, 7, 28));

    expect(viewModel.isFirstEntryExperience, isTrue);
  });

  test('keeps returning experience on an empty selected date', () async {
    final repository = FakeAiEntryRepository()..hasAnyEntriesValue = true;
    final viewModel = AiEntryViewModel(repository, DateTime(2026, 7, 28));
    addTearDown(viewModel.dispose);

    await viewModel.loadDate(DateTime(2026, 7, 28));

    expect(viewModel.entries, isEmpty);
    expect(viewModel.isFirstEntryExperience, isFalse);
  });

  test('leaves first-entry experience after adding an entry', () async {
    final repository = FakeAiEntryRepository()
      ..manualEntry = _entry()
      ..hasAnyEntriesValue = false;
    final viewModel = AiEntryViewModel(repository, DateTime(2026, 7, 28));
    addTearDown(viewModel.dispose);
    await viewModel.loadDate(DateTime(2026, 7, 28));

    repository.result = null;
    repository.entries = [_entry()];
    await viewModel.loadDate(DateTime(2026, 7, 28));

    expect(viewModel.isFirstEntryExperience, isFalse);
  });
}

FinanceEntry _entry() => FinanceEntry(
      id: 'income',
      title: 'Salary',
      categoryName: 'Income',
      amount: 100000,
      occurredAt: DateTime(2026, 7, 28),
      transactionType: 'income',
      currencyCode: 'MGA',
      iconKey: 'income',
      emoji: '💰',
    );
