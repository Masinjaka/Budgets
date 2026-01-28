import 'package:budgets/features/planning/data/datasources/budget_datasource.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_provider.g.dart';

@riverpod
class Budgets extends _$Budgets {
  @override
  Future<List<Budget>> build() {
    return getBudgets();
  }

  Future<void> addSomeBudget(Budget budget) async {
    state = const AsyncValue.loading();
    try {
      await addBudget(budget);
      final budgets = await getBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> updateSomeBudget(Budget budget) async {
    try {
      await updateBudget(budget);
      final budgets = await getBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> deleteSomeBudget(int id) async {
    state = const AsyncValue.loading();
    try {
      await deleteBudget(id);
      final budgets = await getBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }
}
