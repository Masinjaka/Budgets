import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_quota.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/ai_entry/domain/repositories/ai_entry_repository.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/receipts/domain/repositories/receipt_repository.dart';
import 'package:flutter/material.dart';

part 'ai_entry_data_reset.dart';
part 'ai_entry_edit.dart';
part 'ai_entry_receipt.dart';
part 'ai_entry_result_application.dart';
part 'ai_entry_wallets.dart';

class AiEntryViewModel extends ChangeNotifier {
  AiEntryViewModel(this._repository, DateTime initialDate,
      {ReceiptRepository? receiptRepository})
      : _receiptRepository = receiptRepository,
        _selectedDate = DateUtils.dateOnly(initialDate);

  final AiEntryRepository _repository;
  final ReceiptRepository? _receiptRepository;
  DateTime _selectedDate;
  List<FinanceEntry> _entries = const [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  AiQuota? _quota;
  List<WalletSummary> _wallets = const [];
  bool _walletsLoaded = false;
  bool _isAddingWallet = false;
  int _totalFunds = 0;
  bool? _hasAnyEntries;

  DateTime get selectedDate => _selectedDate;
  List<FinanceEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  int? get remainingRequests => _quota?.remaining;
  bool get hasUnlimitedAiRequests => _quota?.unlimited ?? false;
  List<WalletSummary> get wallets => _wallets;
  bool get isAddingWallet => _isAddingWallet;
  int get totalWalletBalance => _totalFunds;
  bool get isFirstEntryExperience => _hasAnyEntries == false;
  String get walletCurrencyCode =>
      _wallets.isEmpty ? 'MGA' : _wallets.first.currencyCode;

  Future<void> loadDate(DateTime date) async {
    _selectedDate = DateUtils.dateOnly(date);
    _isLoading = true;
    notifyListeners();
    final quotaFuture = _quota == null
        ? _repository.aiQuota().then<AiQuota?>((quota) => quota).catchError(
              (_) => null,
            )
        : Future<AiQuota?>.value(_quota);
    final walletsFuture = _walletsLoaded
        ? Future<List<WalletSummary>?>.value(_wallets)
        : _repository
            .wallets()
            .then<List<WalletSummary>?>((wallets) => wallets)
            .catchError((_) => null);
    final totalFuture = _repository
        .totalFunds()
        .then<int?>((value) => value)
        .catchError((_) => null);
    final historyFuture = _hasAnyEntries == null
        ? _repository
            .hasAnyEntries()
            .then<bool?>((value) => value)
            .catchError((_) => null)
        : Future<bool?>.value(_hasAnyEntries);
    try {
      _entries = await _repository.entriesForDate(_selectedDate);
      final hasHistory = await historyFuture;
      _hasAnyEntries = _entries.isNotEmpty || (hasHistory ?? true);
      _quota = await quotaFuture;
      final wallets = await walletsFuture;
      if (wallets != null) {
        _wallets = List.unmodifiable(wallets);
        _walletsLoaded = true;
      }
      _totalFunds = await totalFuture ?? _walletBalance;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AiEntryResult> submit(String message) async {
    final targetDate = _selectedDate;
    _isSubmitting = true;
    notifyListeners();
    try {
      final result = await _repository.processMessage(
        message.trim(),
        targetDate: targetDate,
      );
      await _applyResult(result, targetDate);
      notifyListeners();
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<AiEntryResult> resumeMessage({
    required String requestId,
    required Map<String, dynamic> extraction,
    String? walletId,
    required bool useAllWallets,
  }) async {
    final targetDate = _selectedDate;
    _isSubmitting = true;
    notifyListeners();
    try {
      final result = await _repository.resumeMessage(
        requestId: requestId,
        extraction: extraction,
        walletId: walletId,
        useAllWallets: useAllWallets,
        targetDate: targetDate,
      );
      await _applyResult(result, targetDate);
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> cancelPendingRequest(String requestId) =>
      _repository.cancelPendingRequest(requestId);

  Future<List<ManualEntryCategory>> manualEntryCategories() =>
      _repository.manualEntryCategories();

  Future<FinanceEntry> addManualEntry(ManualEntryInput input) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final entry = await _repository.addManualEntry(input);
      _hasAnyEntries = true;
      if (DateUtils.isSameDay(_selectedDate, input.occurredAt)) {
        _entries = _mergeNewEntries([entry], _entries);
      }
      await refreshBalances();
      notifyListeners();
      return entry;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  int get _walletBalance =>
      _wallets.fold(0, (total, wallet) => total + wallet.balance);

  void _notify() => notifyListeners();

  void _notifyDataReset() => _notify();

  void _notifyReceiptChanged() => _notify();
}
