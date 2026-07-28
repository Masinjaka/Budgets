import 'dart:async';

import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_quota.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/ai_entry/domain/repositories/ai_entry_repository.dart';

class FakeAiEntryRepository implements AiEntryRepository {
  List<FinanceEntry> entries = [];
  AiEntryResult? result;
  DateTime? requestedDate;
  String? submittedMessage;
  DateTime? submittedDate;
  int remaining = 20;
  int dateLoadCount = 0;
  bool hasAnyEntriesValue = false;
  Completer<AiEntryResult>? resultCompleter;
  List<WalletSummary> walletItems = const [];
  List<ManualEntryCategory> manualCategories = const [];
  FinanceEntry? manualEntry;
  ManualEntryInput? addedManualInput;
  ManualEntryInput? updatedManualInput;
  String? updatedEntryId;
  String? deletedEntryId;
  String? updatedWalletId;
  String? deletedWalletId;
  int? totalFundsValue;
  String? cancelledRequestId;
  String? resumedWalletId;
  bool? resumedWithAllWallets;
  Set<DateTime> activityDates = {};
  Completer<Set<DateTime>>? activityDatesCompleter;
  DateTime? requestedActivityMonth;

  @override
  Future<List<FinanceEntry>> entriesForDate(DateTime date) async {
    dateLoadCount++;
    requestedDate = date;
    return List.unmodifiable(entries);
  }

  @override
  Future<bool> hasAnyEntries() async => hasAnyEntriesValue;

  @override
  Future<Set<DateTime>> activityDatesForMonth(DateTime month) async {
    requestedActivityMonth = month;
    if (activityDatesCompleter case final completer?) {
      return completer.future;
    }
    return Set.unmodifiable(activityDates);
  }

  @override
  Future<AiQuota> aiQuota() async =>
      AiQuota(plan: 'free', unlimited: false, remaining: remaining);

  @override
  Future<List<WalletSummary>> wallets() async => List.unmodifiable(walletItems);

  @override
  Future<WalletSummary> addWallet(AddWalletInput input) async {
    final wallet = WalletSummary(
      id: input.name,
      name: input.name,
      balance: input.initialBalance,
      currencyCode: 'MGA',
      iconKey: 'wallet',
      isDefault: false,
    );
    walletItems = [...walletItems, wallet];
    return wallet;
  }

  @override
  Future<WalletSummary> updateWallet(
    String walletId,
    AddWalletInput input,
  ) async {
    updatedWalletId = walletId;
    final current = walletItems.firstWhere((wallet) => wallet.id == walletId);
    final updated = WalletSummary(
      id: current.id,
      name: input.name,
      balance: input.initialBalance,
      currencyCode: current.currencyCode,
      iconKey: current.iconKey,
      isDefault: current.isDefault,
    );
    walletItems = walletItems
        .map((wallet) => wallet.id == walletId ? updated : wallet)
        .toList();
    return updated;
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    deletedWalletId = walletId;
    walletItems = walletItems.where((wallet) => wallet.id != walletId).toList();
  }

  @override
  Future<int> totalFunds() async =>
      totalFundsValue ??
      walletItems.fold<int>(0, (total, wallet) => total + wallet.balance);

  @override
  Future<List<ManualEntryCategory>> manualEntryCategories() async =>
      manualCategories;

  @override
  Future<FinanceEntry> addManualEntry(ManualEntryInput input) async {
    addedManualInput = input;
    return manualEntry ??
        FinanceEntry(
          id: 'manual',
          title: input.title,
          description: input.description,
          categoryName: 'Other',
          amount: input.amount.toDouble(),
          occurredAt: input.occurredAt,
          transactionType: input.transactionType,
          currencyCode: 'MGA',
          iconKey: 'other',
          emoji: '🧾',
        );
  }

  @override
  Future<FinanceEntry> updateFinanceEntry(
    String entryId,
    ManualEntryInput input,
  ) async {
    updatedEntryId = entryId;
    updatedManualInput = input;
    final updated = FinanceEntry(
      id: entryId,
      title: input.title,
      description: input.description,
      categoryName: 'Other',
      amount: input.amount.toDouble(),
      occurredAt: input.occurredAt,
      transactionType: input.transactionType,
      currencyCode: 'MGA',
      iconKey: 'other',
      emoji: '🧾',
      categoryId: input.categoryId,
    );
    entries =
        entries.map((entry) => entry.id == entryId ? updated : entry).toList();
    return updated;
  }

  @override
  Future<void> deleteFinanceEntry(String entryId) async {
    deletedEntryId = entryId;
    entries = entries.where((entry) => entry.id != entryId).toList();
  }

  @override
  Future<AiEntryResult> processMessage(
    String message, {
    required DateTime targetDate,
  }) async {
    submittedMessage = message;
    submittedDate = targetDate;
    if (resultCompleter case final completer?) return completer.future;
    return result ??
        const AiEntryResult(
          entries: [],
          message: 'No entry found.',
          remaining: 19,
          provider: 'gemini',
          model: 'gemini-2.5-flash-lite',
          billingTier: 'free',
        );
  }

  @override
  Future<AiEntryResult> resumeMessage({
    required String requestId,
    required Map<String, dynamic> extraction,
    String? walletId,
    required bool useAllWallets,
    required DateTime targetDate,
  }) {
    resumedWalletId = walletId;
    resumedWithAllWallets = useAllWallets;
    return processMessage('resume', targetDate: targetDate);
  }

  @override
  Future<void> cancelPendingRequest(String requestId) async {
    cancelledRequestId = requestId;
  }
}
