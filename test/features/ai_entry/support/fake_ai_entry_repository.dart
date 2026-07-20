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
  Completer<AiEntryResult>? resultCompleter;
  List<WalletSummary> walletItems = const [];
  List<ManualEntryCategory> manualCategories = const [];
  FinanceEntry? manualEntry;
  ManualEntryInput? addedManualInput;
  int? totalFundsValue;
  String? cancelledRequestId;
  String? resumedWalletId;
  bool? resumedWithAllWallets;
  Set<DateTime> activityDates = {};
  DateTime? requestedActivityMonth;

  @override
  Future<List<FinanceEntry>> entriesForDate(DateTime date) async {
    dateLoadCount++;
    requestedDate = date;
    return List.unmodifiable(entries);
  }

  @override
  Future<Set<DateTime>> activityDatesForMonth(DateTime month) async {
    requestedActivityMonth = month;
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
