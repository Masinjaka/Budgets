import 'package:budgets/features/planning/data/datasources/budget_datasource.dart';
import 'package:budgets/features/planning/data/datasources/budget_history_datasource.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_provider.g.dart';

@riverpod
class Budgets extends _$Budgets {
  @override
  Future<List<Budget>> build() async {
    final budgets = await getBudgets();

    // Check if we need to reset budgets based on each budget period
    try {
      final didReset = await checkAndResetBudgetsByPeriod(budgets);
      if (didReset) {
        // If reset happened, fetch fresh data
        debugPrint('Budgets were reset based on period, fetching fresh data');
        return await getBudgets();
      }
    } catch (e) {
      debugPrint('Error checking budget reset: $e');
      // Continue with current data even if reset check fails
    }

    return budgets;
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
