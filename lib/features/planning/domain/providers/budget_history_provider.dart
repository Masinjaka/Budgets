import 'package:budgets/features/planning/data/datasources/budget_history_datasource.dart';
import 'package:budgets/features/planning/domain/models/budget_history_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_history_provider.g.dart';

@riverpod
class BudgetHistoryForMonth extends _$BudgetHistoryForMonth {
  late String _periodMonth;
  
  @override
  Future<List<BudgetHistory>> build(String periodMonth) {
    _periodMonth = periodMonth;
    return getBudgetHistoryForMonth(periodMonth);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final history = await getBudgetHistoryForMonth(_periodMonth);
      state = AsyncValue.data(history);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

@riverpod
class AllBudgetHistory extends _$AllBudgetHistory {
  @override
  Future<List<BudgetHistory>> build() {
    return getAllBudgetHistory();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final history = await getAllBudgetHistory();
      state = AsyncValue.data(history);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
