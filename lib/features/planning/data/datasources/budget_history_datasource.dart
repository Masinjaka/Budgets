import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/planning/domain/models/budget_history_model.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:flutter/foundation.dart';

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

const Set<String> _supportedBudgetPeriods = {
  'weekly',
  'biweekly',
  'monthly',
  'bimonthly',
  'yearly',
};

String normalizeBudgetPeriod(String? period) {
  if (period == null) return 'monthly';
  final normalized = period.toLowerCase().trim();
  return _supportedBudgetPeriods.contains(normalized) ? normalized : 'monthly';
}

DateTime _startOfWeek(DateTime date) {
  final localDate = DateTime(date.year, date.month, date.day);
  return localDate.subtract(Duration(days: localDate.weekday - 1));
}

bool _isResetDue({
  required DateTime now,
  required DateTime lastResetAt,
  required String period,
}) {
  switch (period) {
    case 'weekly':
      return _startOfWeek(now).isAfter(_startOfWeek(lastResetAt));
    case 'biweekly':
      return now.difference(lastResetAt).inDays >= 14;
    case 'bimonthly':
      final nowBucket = ((now.month - 1) ~/ 2) + 1;
      final resetBucket = ((lastResetAt.month - 1) ~/ 2) + 1;
      return now.year > lastResetAt.year ||
          (now.year == lastResetAt.year && nowBucket > resetBucket);
    case 'yearly':
      return now.year > lastResetAt.year;
    case 'monthly':
    default:
      return now.year > lastResetAt.year ||
          (now.year == lastResetAt.year && now.month > lastResetAt.month);
  }
}

String _historyPeriodKey({
  required DateTime referenceDate,
  required String period,
}) {
  final year = referenceDate.year;
  final month = referenceDate.month.toString().padLeft(2, '0');
  final day = referenceDate.day.toString().padLeft(2, '0');
  switch (period) {
    case 'weekly':
      final weekStart = _startOfWeek(referenceDate);
      final weekMonth = weekStart.month.toString().padLeft(2, '0');
      final weekDay = weekStart.day.toString().padLeft(2, '0');
      return 'weekly:${weekStart.year}-$weekMonth-$weekDay';
    case 'biweekly':
      return 'biweekly:$year-$month-$day';
    case 'bimonthly':
      final bucket = ((referenceDate.month - 1) ~/ 2) + 1;
      return 'bimonthly:$year-B$bucket';
    case 'yearly':
      return 'yearly:$year';
    case 'monthly':
    default:
      return '$year-$month';
  }
}

/// Archive current budgets to history with a period key per budget ID.
Future<void> archiveBudgetsToHistory(
  List<Budget> budgets,
  Map<int, String> periodKeyByBudgetId,
) {
  return Wrapper.execute(() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final historyRecords = budgets.where((budget) {
      final hasId = budget.id != null;
      final hasPeriodKey = periodKeyByBudgetId.containsKey(budget.id);
      final spent = double.tryParse(budget.amountSpent ?? '0') ?? 0;
      return hasId && hasPeriodKey && spent > 0;
    }).map((budget) {
      return {
        'budget_id': budget.id,
        'user_id': userId,
        'category': budget.category?.id,
        'amount': budget.amount,
        'amount_spent': budget.amountSpent,
        'period_month': periodKeyByBudgetId[budget.id]!,
      };
    }).toList();

    if (historyRecords.isEmpty) {
      return;
    }

    await supabase.from('budget_history').insert(historyRecords);
    debugPrint('Archived ${historyRecords.length} budgets to history');
  });
}

/// Reset selected budget spent amounts and move their reset baseline to now.
Future<void> resetBudgetsSpent(List<int> budgetIds) {
  return Wrapper.execute(() async {
    if (budgetIds.isEmpty) return;

    final nowIso = DateTime.now().toIso8601String();
    for (final id in budgetIds) {
      await supabase.from('budgets').update({
        'amount_spent': '0',
        'last_reset_at': nowIso,
      }).eq('id', id);
    }
  });
}

/// Reset budgets whose configured period has elapsed.
/// Returns true if at least one budget was reset.
Future<bool> checkAndResetBudgetsByPeriod(List<Budget> currentBudgets) async {
  if (currentBudgets.isEmpty) return false;

  final now = DateTime.now();
  final dueBudgets = <Budget>[];
  final periodKeyByBudgetId = <int, String>{};

  for (final budget in currentBudgets) {
    final id = budget.id;
    if (id == null) continue;

    final period = normalizeBudgetPeriod(budget.period);
    final lastResetAt = budget.lastResetAt ?? budget.createdAt ?? now;
    final due = _isResetDue(
      now: now,
      lastResetAt: lastResetAt,
      period: period,
    );
    if (!due) continue;

    dueBudgets.add(budget);
    periodKeyByBudgetId[id] = _historyPeriodKey(
      referenceDate: lastResetAt,
      period: period,
    );
  }

  if (dueBudgets.isEmpty) {
    return false;
  }

  try {
    await archiveBudgetsToHistory(dueBudgets, periodKeyByBudgetId);
    await resetBudgetsSpent(dueBudgets.map((b) => b.id!).toList());
    debugPrint('Budget reset completed for ${dueBudgets.length} budgets');
    return true;
  } catch (e) {
    debugPrint('Error during budget reset: $e');
    rethrow;
  }
}

/// Get the formatted period month string from a DateTime
String getPeriodMonthString(DateTime date) {
  return _historyPeriodKey(
    referenceDate: date,
    period: 'monthly',
  );
}

/// Delete a budget history record by ID
Future<void> deleteBudgetHistory(String id) {
  return Wrapper.execute(() async {
    await supabase.from('budget_history').delete().eq('id', id);
  });
}
