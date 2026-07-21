import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_quota.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/ai_entry/domain/repositories/ai_entry_repository.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:flutter/material.dart';

part 'ai_entry_data_reset.dart';

class AiEntryViewModel extends ChangeNotifier {
  AiEntryViewModel(this._repository, DateTime initialDate)
      : _selectedDate = DateUtils.dateOnly(initialDate);

  final AiEntryRepository _repository;
  DateTime _selectedDate;
  List<FinanceEntry> _entries = const [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  AiQuota? _quota;
  List<WalletSummary> _wallets = const [];
  bool _walletsLoaded = false;
  bool _isAddingWallet = false;
  int _totalFunds = 0;

  DateTime get selectedDate => _selectedDate;
  List<FinanceEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  int? get remainingRequests => _quota?.remaining;
  bool get hasUnlimitedAiRequests => _quota?.unlimited ?? false;
  List<WalletSummary> get wallets => _wallets;
  bool get isAddingWallet => _isAddingWallet;
  int get totalWalletBalance => _totalFunds;
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
    try {
      _entries = await _repository.entriesForDate(_selectedDate);
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

  Future<void> addWallet(AddWalletInput input) async {
    if (_isAddingWallet) return;
    _isAddingWallet = true;
    notifyListeners();
    try {
      final wallet = await _repository.addWallet(input);
      _wallets = List.unmodifiable([..._wallets, wallet]);
      _walletsLoaded = true;
      _totalFunds = await _repository.totalFunds();
    } finally {
      _isAddingWallet = false;
      notifyListeners();
    }
  }

  Future<List<ManualEntryCategory>> manualEntryCategories() =>
      _repository.manualEntryCategories();

  Future<FinanceEntry> addManualEntry(ManualEntryInput input) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final entry = await _repository.addManualEntry(input);
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

  Future<void> refreshBalances() async {
    _wallets = List.unmodifiable(await _repository.wallets());
    _walletsLoaded = true;
    _totalFunds = await _repository.totalFunds();
    notifyListeners();
  }

  int get _walletBalance =>
      _wallets.fold(0, (total, wallet) => total + wallet.balance);

  void _notifyDataReset() => notifyListeners();

  Future<void> _applyResult(AiEntryResult result, DateTime targetDate) async {
    _quota = AiQuota(
      plan: result.plan,
      unlimited: result.unlimited,
      remaining: result.remaining,
    );
    if (DateUtils.isSameDay(_selectedDate, targetDate)) {
      _entries = _mergeNewEntries(result.entries, _entries);
    }
    await refreshBalances();
  }

  List<FinanceEntry> _mergeNewEntries(
    List<FinanceEntry> additions,
    List<FinanceEntry> existing,
  ) {
    if (additions.isEmpty) return existing;
    final addedIds = additions.map((entry) => entry.id).toSet();
    return List.unmodifiable([
      ...additions,
      ...existing.where((entry) => !addedIds.contains(entry.id)),
    ]);
  }
}
