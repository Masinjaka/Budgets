import 'package:budgets/features/stats/domain/models/monthly_stats.dart';
import 'package:budgets/features/stats/domain/repositories/monthly_stats_repository.dart';
import 'package:flutter/foundation.dart';

class MonthlyStatsViewModel extends ChangeNotifier {
  MonthlyStatsViewModel(this._repository, DateTime initialMonth)
      : _month = DateTime(initialMonth.year, initialMonth.month);

  final MonthlyStatsRepository _repository;
  DateTime _month;
  MonthlyStats? _stats;
  bool _isLoading = false;

  DateTime get month => _month;
  MonthlyStats? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _stats = await _repository.statsForMonth(_month);
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
}
