import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_quota.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';

abstract interface class AiEntryRepository {
  Future<List<FinanceEntry>> entriesForDate(DateTime date);

  Future<Set<DateTime>> activityDatesForMonth(DateTime month);

  Future<AiQuota> aiQuota();

  Future<List<WalletSummary>> wallets();

  Future<WalletSummary> addWallet(AddWalletInput input);

  Future<int> totalFunds();

  Future<List<ManualEntryCategory>> manualEntryCategories();

  Future<FinanceEntry> addManualEntry(ManualEntryInput input);

  Future<FinanceEntry> updateFinanceEntry(
    String entryId,
    ManualEntryInput input,
  );

  Future<void> deleteFinanceEntry(String entryId);

  Future<AiEntryResult> processMessage(
    String message, {
    required DateTime targetDate,
  });

  Future<AiEntryResult> resumeMessage({
    required String requestId,
    required Map<String, dynamic> extraction,
    String? walletId,
    required bool useAllWallets,
    required DateTime targetDate,
  });

  Future<void> cancelPendingRequest(String requestId);
}
