import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_ai_entry_repository.dart';

void main() {
  test('refreshes the default wallet balance after AI income', () async {
    final repository = FakeAiEntryRepository()
      ..walletItems = [_wallet(400000)]
      ..result = AiEntryResult(
        entries: [_incomeEntry()],
        message: 'Income added.',
        remaining: 19,
        provider: 'gemini',
        model: 'gemini-2.5-flash-lite',
        billingTier: 'free',
      );
    final viewModel = AiEntryViewModel(repository, DateTime(2026, 7, 17));
    await viewModel.loadDate(DateTime(2026, 7, 17));

    repository.walletItems = [_wallet(650000)];
    await viewModel.submit('I received 250000 Ar');

    expect(viewModel.wallets.single.isDefault, isTrue);
    expect(viewModel.wallets.single.balance, 650000);
    expect(viewModel.totalWalletBalance, 650000);
  });
}

FinanceEntry _incomeEntry() => FinanceEntry(
      id: 'income',
      title: 'Revenue',
      categoryName: 'Other income',
      amount: 250000,
      occurredAt: DateTime(2026, 7, 17),
      transactionType: 'income',
      currencyCode: 'MGA',
      iconKey: 'income',
      emoji: '💰',
    );

WalletSummary _wallet(int balance) => WalletSummary(
      id: 'cash',
      name: 'Cash',
      balance: balance,
      currencyCode: 'MGA',
      iconKey: 'wallet',
      isDefault: true,
    );
