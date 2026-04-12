import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/planning/domain/models/budget_history_model.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Build a [BudgetHistory] from a PowerSync JOIN row.
BudgetHistory _budgetHistoryFromRow(Map<String, dynamic> row) {
  return BudgetHistory(
    id: row['id'] as String?,
    createdAt: row['created_at'] != null
        ? DateTime.parse(row['created_at'] as String)
        : null,
    budgetId: row['budget_id']?.toString(),
    userId: row['user_id'] as String?,
    category: row['cat_id'] != null
        ? Category(
            id: row['cat_id'] as String?,
            name: row['cat_name'] as String?,
            emoji: row['cat_emoji'] as String?,
            color: row['cat_color'] as String?,
          )
        : null,
    amount: row['amount'] as String?,
    amountSpent: row['amount_spent'] as String?,
    periodMonth: row['period_month'] as String?,
  );
}

/// Get budget history for a specific month
/// [periodMonth] should be in format "YYYY-MM" e.g. "2026-01"
Future<List<BudgetHistory>> getBudgetHistoryForMonth(String periodMonth) {
  return Wrapper.execute(() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final results = await powersync.db.getAll('''
      SELECT bh.id, bh.created_at, bh.budget_id, bh.user_id,
             bh.amount, bh.amount_spent, bh.period_month,
             c.id AS cat_id, c.name AS cat_name, c.emoji AS cat_emoji,
             c.color AS cat_color, c.transaction_type AS cat_type
      FROM budget_history bh
      LEFT JOIN categories c ON bh.category = c.id
      WHERE bh.user_id = ? AND bh.period_month = ?
      ORDER BY bh.created_at ASC
    ''', [userId, periodMonth]);

    if (results.isEmpty) return [];

    return results.map((row) => _budgetHistoryFromRow(row)).toList();
  });
}

/// Get all budget history for the current user
Future<List<BudgetHistory>> getAllBudgetHistory() {
  return Wrapper.execute(() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final results = await powersync.db.getAll('''
      SELECT bh.id, bh.created_at, bh.budget_id, bh.user_id,
             bh.amount, bh.amount_spent, bh.period_month,
             c.id AS cat_id, c.name AS cat_name, c.emoji AS cat_emoji,
             c.color AS cat_color, c.transaction_type AS cat_type
      FROM budget_history bh
      LEFT JOIN categories c ON bh.category = c.id
      WHERE bh.user_id = ?
      ORDER BY bh.period_month DESC
    ''', [userId]);

    if (results.isEmpty) return [];

    return results.map((row) => _budgetHistoryFromRow(row)).toList();
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
  Map<String, String> periodKeyByBudgetId,
) {
  return Wrapper.execute(() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final historyRecords = budgets.where((budget) {
      final hasId = budget.id != null;
      final hasPeriodKey = periodKeyByBudgetId.containsKey(budget.id);
      final spent = double.tryParse(budget.amountSpent ?? '0') ?? 0;
      return hasId && hasPeriodKey && spent > 0;
    }).toList();

    if (historyRecords.isEmpty) return;

    final nowIso = DateTime.now().toUtc().toIso8601String();

    await powersync.db.writeTransaction((tx) async {
      for (final budget in historyRecords) {
        final historyId = _uuid.v4();
        await tx.execute(
          '''INSERT INTO budget_history
             (id, created_at, budget_id, user_id, category, amount, amount_spent, period_month)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
          [
            historyId,
            nowIso,
            budget.id,
            userId,
            budget.category?.id,
            budget.amount,
            budget.amountSpent,
            periodKeyByBudgetId[budget.id]!,
          ],
        );
      }
    });

    debugPrint('Archived ${historyRecords.length} budgets to history');
  });
}

/// Reset selected budget spent amounts and move their reset baseline to now.
Future<void> resetBudgetsSpent(List<String> budgetIds) {
  return Wrapper.execute(() async {
    if (budgetIds.isEmpty) return;

    final nowIso = DateTime.now().toUtc().toIso8601String();

    await powersync.db.writeTransaction((tx) async {
      for (final id in budgetIds) {
        await tx.execute(
          '''UPDATE budgets
             SET amount_spent = '0', last_reset_at = ?
             WHERE id = ?''',
          [nowIso, id],
        );
      }
    });
  });
}

/// Reset budgets whose configured period has elapsed.
/// Returns true if at least one budget was reset.
Future<bool> checkAndResetBudgetsByPeriod(List<Budget> currentBudgets) async {
  if (currentBudgets.isEmpty) return false;

  final now = DateTime.now();
  final dueBudgets = <Budget>[];
  final periodKeyByBudgetId = <String, String>{};

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
    await powersync.db.execute(
      'DELETE FROM budget_history WHERE id = ?',
      [id],
    );
  });
}
