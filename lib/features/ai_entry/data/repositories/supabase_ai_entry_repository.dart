import 'package:budgets/features/ai_entry/data/services/ai_entry_service.dart';
import 'package:budgets/features/ai_entry/data/services/manual_entry_service.dart';
import 'package:budgets/features/ai_entry/data/services/wallet_service.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_quota.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/ai_entry/domain/repositories/ai_entry_repository.dart';

class SupabaseAiEntryRepository implements AiEntryRepository {
  const SupabaseAiEntryRepository(
    this._service,
    this._manualEntryService,
    this._walletService,
  );

  final AiEntryService _service;
  final ManualEntryService _manualEntryService;
  final WalletService _walletService;

  @override
  Future<List<FinanceEntry>> entriesForDate(DateTime date) =>
      _service.entriesForDate(date);

  @override
  Future<bool> hasAnyEntries() => _service.hasAnyEntries();

  @override
  Future<Set<DateTime>> activityDatesForMonth(DateTime month) =>
      _service.activityDatesForMonth(month);

  @override
  Future<AiQuota> aiQuota() => _service.aiQuota();

  @override
  Future<List<WalletSummary>> wallets() => _walletService.wallets();

  @override
  Future<WalletSummary> addWallet(AddWalletInput input) =>
      _walletService.add(input);

  @override
  Future<WalletSummary> updateWallet(
    String walletId,
    AddWalletInput input,
  ) =>
      _walletService.update(walletId, input);

  @override
  Future<void> deleteWallet(String walletId) => _walletService.delete(walletId);

  @override
  Future<int> totalFunds() => _walletService.totalFunds();

  @override
  Future<List<ManualEntryCategory>> manualEntryCategories() =>
      _manualEntryService.categories();

  @override
  Future<FinanceEntry> addManualEntry(ManualEntryInput input) =>
      _manualEntryService.add(input);

  @override
  Future<FinanceEntry> updateFinanceEntry(
    String entryId,
    ManualEntryInput input,
  ) =>
      _manualEntryService.update(entryId, input);

  @override
  Future<void> deleteFinanceEntry(String entryId) =>
      _manualEntryService.delete(entryId);

  @override
  Future<AiEntryResult> processMessage(
    String message, {
    required DateTime targetDate,
  }) =>
      _service.processMessage(message, targetDate: targetDate);

  @override
  Future<AiEntryResult> resumeMessage({
    required String requestId,
    required Map<String, dynamic> extraction,
    String? walletId,
    required bool useAllWallets,
    required DateTime targetDate,
  }) =>
      _service.resumeMessage(
        requestId: requestId,
        extraction: extraction,
        walletId: walletId,
        useAllWallets: useAllWallets,
        targetDate: targetDate,
      );

  @override
  Future<void> cancelPendingRequest(String requestId) =>
      _service.cancelPendingRequest(requestId);
}
