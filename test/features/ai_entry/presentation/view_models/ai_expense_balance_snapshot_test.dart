import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/view_models/ai_entry_view_model.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_ai_entry_repository.dart';

void main() {
  test('applies the committed wallet snapshot after an AI expense', () async {
    final repository = FakeAiEntryRepository()
      ..walletItems = const [_initialWallet]
      ..result = AiEntryResult(
        entries: [_expense],
        message: 'Expense added.',
        remaining: 19,
        provider: 'gemini',
        model: 'gemini-2.5-flash-lite',
        billingTier: 'free',
        wallets: const [_updatedWallet],
        totalFunds: 878700,
      );
    final viewModel = AiEntryViewModel(repository, DateTime(2026, 7, 25));
    await viewModel.loadDate(DateTime(2026, 7, 25));

    await viewModel.submit('I spent 3000 Ar on coffee');

    expect(viewModel.wallets.single.balance, 397000);
    expect(viewModel.totalWalletBalance, 397000);
  });
}

const _initialWallet = WalletSummary(
  id: 'cash',
  name: 'Cash',
  balance: 400000,
  currencyCode: 'MGA',
  iconKey: 'wallet',
  isDefault: true,
);

const _updatedWallet = WalletSummary(
  id: 'cash',
  name: 'Cash',
  balance: 397000,
  currencyCode: 'MGA',
  iconKey: 'wallet',
  isDefault: true,
);

final _expense = FinanceEntry(
  id: 'coffee',
  title: 'Coffee',
  categoryName: 'Food',
  amount: 3000,
  occurredAt: DateTime(2026, 7, 25),
  transactionType: 'expense',
  currencyCode: 'MGA',
  iconKey: 'food',
  emoji: '☕',
);
