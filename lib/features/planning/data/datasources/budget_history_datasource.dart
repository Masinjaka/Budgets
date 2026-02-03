import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/planning/domain/models/budget_history_model.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _lastResetMonthKey = 'last_budget_reset_month';

/// Get budget history for a specific month
/// [periodMonth] should be in format "YYYY-MM" e.g. "2026-01"
Future<List<BudgetHistory>> getBudgetHistoryForMonth(String periodMonth) {
  return Wrapper.execute(() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('budget_history')
        .select(
            'id, created_at, budget_id, user_id, category (id, name, emoji, color, transaction_type), amount, amount_spent, period_month')
        .eq('user_id', userId)
        .eq('period_month', periodMonth)
        .order('created_at', ascending: true);

    if (response.isEmpty) return [];

    return (response as List)
        .map((item) => BudgetHistory.fromMap(item))
        .toList();
  });
}

/// Get all budget history for the current user
Future<List<BudgetHistory>> getAllBudgetHistory() {
  return Wrapper.execute(() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('budget_history')
        .select(
            'id, created_at, budget_id, user_id, category (id, name, emoji, color, transaction_type), amount, amount_spent, period_month')
        .eq('user_id', userId)
        .order('period_month', ascending: false);

    if (response.isEmpty) return [];

    return (response as List)
        .map((item) => BudgetHistory.fromMap(item))
        .toList();
  });
}

/// Archive current budgets to history for a specific period month
/// This creates a snapshot of all current budgets with their spent amounts
Future<void> archiveBudgetsToHistory(
    List<Budget> budgets, String periodMonth) {
  return Wrapper.execute(() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Only archive budgets that have some spending
    final budgetsToArchive = budgets.where((b) {
      final spent = double.tryParse(b.amountSpent ?? '0') ?? 0;
      return spent > 0;
    }).toList();

    if (budgetsToArchive.isEmpty) {
      debugPrint('No budgets with spending to archive for $periodMonth');
      return;
    }

    final historyRecords = budgetsToArchive.map((budget) => {
          'budget_id': budget.id,
          'user_id': userId,
          'category': budget.category?.id,
          'amount': budget.amount,
          'amount_spent': budget.amountSpent,
          'period_month': periodMonth,
        }).toList();

    await supabase.from('budget_history').insert(historyRecords);
    debugPrint(
        'Archived ${historyRecords.length} budgets to history for $periodMonth');
  });
}

/// Reset all budget spent amounts to zero
Future<void> resetAllBudgetsSpent() {
  return Wrapper.execute(() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await supabase
        .from('budgets')
        .update({'amount_spent': '0'}).eq('user_id', userId);

    debugPrint('Reset all budget spent amounts to zero');
  });
}

/// Check if we need to reset budgets for a new month and perform reset if needed
/// Returns true if a reset was performed
Future<bool> checkAndResetIfNewMonth(List<Budget> currentBudgets) async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

  final lastResetMonth = prefs.getString(_lastResetMonthKey);

  debugPrint('Current month: $currentMonth, Last reset: $lastResetMonth');

  if (lastResetMonth == null) {
    // First time - just set the current month without resetting
    await prefs.setString(_lastResetMonthKey, currentMonth);
    debugPrint('First time setup - set last reset month to $currentMonth');
    return false;
  }

  if (lastResetMonth != currentMonth) {
    // New month detected - archive and reset
    debugPrint('New month detected! Archiving budgets for $lastResetMonth');

    try {
      // Archive current budgets to history with the PREVIOUS month
      await archiveBudgetsToHistory(currentBudgets, lastResetMonth);

      // Reset all budget spent amounts
      await resetAllBudgetsSpent();

      // Update last reset month
      await prefs.setString(_lastResetMonthKey, currentMonth);

      debugPrint('Monthly budget reset completed successfully');
      return true;
    } catch (e) {
      debugPrint('Error during monthly budget reset: $e');
      rethrow;
    }
  }

  return false;
}

/// Get the formatted period month string from a DateTime
String getPeriodMonthString(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

/// Delete a budget history record by ID
Future<void> deleteBudgetHistory(String id) {
  return Wrapper.execute(() async {
    await supabase.from('budget_history').delete().eq('id', id);
  });
}
