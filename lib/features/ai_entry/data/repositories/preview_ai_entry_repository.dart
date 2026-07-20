import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_quota.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/ai_entry/domain/repositories/ai_entry_repository.dart';

class PreviewAiEntryRepository implements AiEntryRepository {
  const PreviewAiEntryRepository(this.today);

  final DateTime today;

  @override
  Future<AiQuota> aiQuota() async =>
      const AiQuota(plan: 'free', unlimited: false, remaining: 20);

  @override
  Future<List<WalletSummary>> wallets() async => const [
        WalletSummary(
          id: 'cash',
          name: 'Cash',
          balance: 400000,
          currencyCode: 'MGA',
          iconKey: 'wallet',
          isDefault: true,
        ),
        WalletSummary(
          id: 'bank',
          name: 'Bank account',
          balance: 600000,
          currencyCode: 'MGA',
          iconKey: 'bank',
          isDefault: false,
        ),
      ];

  @override
  Future<WalletSummary> addWallet(AddWalletInput input) async => WalletSummary(
        id: input.name,
        name: input.name,
        balance: input.initialBalance,
        currencyCode: 'MGA',
        iconKey: 'wallet',
        isDefault: false,
      );

  @override
  Future<int> totalFunds() async => 1000000;

  @override
  Future<List<ManualEntryCategory>> manualEntryCategories() async => const [];

  @override
  Future<FinanceEntry> addManualEntry(ManualEntryInput input) {
    throw StateError('Supabase is not initialized.');
  }

  @override
  Future<List<FinanceEntry>> entriesForDate(DateTime date) async {
    if (date.year != today.year ||
        date.month != today.month ||
        date.day != today.day) {
      return const [];
    }
    return [
      _entry('1', 'Burgers & Fries', 'Foods & Drinks', 'food'),
      _entry('2', 'Gift', 'Shopping', 'shopping'),
      _entry('3', 'Alcohol', 'Foods & Drinks', 'food'),
    ];
  }

  @override
  Future<Set<DateTime>> activityDatesForMonth(DateTime month) async {
    if (month.year != today.year || month.month != today.month) return {};
    return {DateTime(today.year, today.month, today.day)};
  }

  FinanceEntry _entry(
    String id,
    String title,
    String category,
    String icon,
  ) =>
      FinanceEntry(
        id: id,
        title: title,
        categoryName: category,
        amount: 3.99,
        occurredAt: today,
        transactionType: 'expense',
        currencyCode: 'USD',
        iconKey: icon,
        emoji: '🧾',
      );

  @override
  Future<AiEntryResult> processMessage(
    String message, {
    required DateTime targetDate,
  }) {
    throw StateError('Supabase is not initialized.');
  }

  @override
  Future<AiEntryResult> resumeMessage({
    required String requestId,
    required Map<String, dynamic> extraction,
    String? walletId,
    required bool useAllWallets,
    required DateTime targetDate,
  }) {
    throw StateError('Supabase is not initialized.');
  }

  @override
  Future<void> cancelPendingRequest(String requestId) async {}
}
