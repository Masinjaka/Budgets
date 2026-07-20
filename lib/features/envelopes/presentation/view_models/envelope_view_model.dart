import 'package:budgets/features/envelopes/domain/models/envelope.dart';
import 'package:budgets/features/envelopes/domain/models/envelope_category.dart';
import 'package:budgets/features/envelopes/domain/repositories/envelope_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';

class EnvelopeViewModel extends ChangeNotifier {
  EnvelopeViewModel(this._repository, DateTime initialMonth)
      : _month = DateTime(initialMonth.year, initialMonth.month);

  final EnvelopeRepository _repository;
  DateTime _month;
  List<Envelope> _envelopes = const [];
  List<EnvelopeCategory> _categories = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  List<WalletSummary> _wallets = const [];

  DateTime get month => _month;
  List<Envelope> get envelopes => _envelopes;
  List<EnvelopeCategory> get availableCategories {
    final used = _envelopes.map((item) => item.categoryId).toSet();
    return _categories.where((item) => !used.contains(item.id)).toList();
  }

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  List<WalletSummary> get wallets => _wallets;
  int get totalBudget =>
      _envelopes.fold(0, (total, item) => total + item.amount);
  int get totalSpent => _envelopes.fold(0, (total, item) => total + item.spent);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final values = await Future.wait([
        _repository.envelopesForMonth(_month),
        _repository.expenseCategories(),
        _repository.wallets(),
      ]);
      _envelopes = List.unmodifiable(values[0] as List<Envelope>);
      _categories = List.unmodifiable(values[1] as List<EnvelopeCategory>);
      _wallets = List.unmodifiable(values[2] as List<WalletSummary>);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeMonth(int offset) async {
    final candidate = DateTime(_month.year, _month.month + offset);
    final now = DateTime.now();
    if (candidate.isAfter(DateTime(now.year, now.month))) return;
    _month = candidate;
    await load();
  }

  Future<void> add({
    required String name,
    required String categoryId,
    required int amount,
    String? walletId,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.addEnvelope(
        name: name,
        categoryId: categoryId,
        amount: amount,
        month: _month,
        walletId: walletId,
      );
      await load();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    await _repository.deleteEnvelope(id);
    _envelopes = List.unmodifiable(
      _envelopes.where((item) => item.id != id),
    );
    notifyListeners();
  }
}
