import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/planning/domain/models/budget_history_model.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _historySelect =
    'id, created_at, budget_id, user_id, amount, amount_spent, period_month, '
    'category_data:categories!budget_history_category_fkey'
    '(id, name, emoji, color)';
const _supportedPeriods = {
  'weekly',
  'biweekly',
  'monthly',
  'bimonthly',
  'yearly',
};

BudgetHistory _fromRow(Map<String, dynamic> row) {
  final category = row['category_data'] as Map<String, dynamic>?;
  return BudgetHistory(
    id: row['id'] as String?,
    createdAt: DateTime.tryParse(row['created_at']?.toString() ?? ''),
    budgetId: row['budget_id']?.toString(),
    userId: row['user_id'] as String?,
    category: category == null
        ? null
        : Category(
            id: category['id'] as String?,
            name: category['name'] as String?,
            emoji: category['emoji'] as String?,
            color: category['color'] as String?,
          ),
    amount: row['amount'] as String?,
    amountSpent: row['amount_spent'] as String?,
    periodMonth: row['period_month'] as String?,
  );
}

Future<List<BudgetHistory>> getBudgetHistoryForMonth(String periodMonth) {
  return Wrapper.execute(() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await client
        .from('budget_history')
        .select(_historySelect)
        .eq('user_id', userId)
        .eq('period_month', periodMonth)
        .order('created_at');
    return rows.map(_fromRow).toList();
  });
}

Future<List<BudgetHistory>> getAllBudgetHistory() {
  return Wrapper.execute(() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await client
        .from('budget_history')
        .select(_historySelect)
        .eq('user_id', userId)
        .order('period_month', ascending: false);
    return rows.map(_fromRow).toList();
  });
}

String normalizeBudgetPeriod(String? period) {
  final value = period?.toLowerCase().trim() ?? 'monthly';
  return _supportedPeriods.contains(value) ? value : 'monthly';
}

DateTime _startOfWeek(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

bool _isResetDue(DateTime now, DateTime resetAt, String period) {
  switch (period) {
    case 'weekly':
      return _startOfWeek(now).isAfter(_startOfWeek(resetAt));
    case 'biweekly':
      return now.difference(resetAt).inDays >= 14;
    case 'bimonthly':
      final nowBucket = (now.month - 1) ~/ 2;
      final resetBucket = (resetAt.month - 1) ~/ 2;
      return now.year > resetAt.year ||
          now.year == resetAt.year && nowBucket > resetBucket;
    case 'yearly':
      return now.year > resetAt.year;
    default:
      return now.year > resetAt.year ||
          now.year == resetAt.year && now.month > resetAt.month;
  }
}

String _periodKey(DateTime date, String period) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  if (period == 'weekly') {
    final start = _startOfWeek(date);
    final m = start.month.toString().padLeft(2, '0');
    final d = start.day.toString().padLeft(2, '0');
    return 'weekly:${start.year}-$m-$d';
  }
  if (period == 'biweekly') return 'biweekly:${date.year}-$month-$day';
  if (period == 'bimonthly') {
    return 'bimonthly:${date.year}-B${((date.month - 1) ~/ 2) + 1}';
  }
  if (period == 'yearly') return 'yearly:${date.year}';
  return '${date.year}-$month';
}

Future<void> archiveBudgetsToHistory(
  List<Budget> budgets,
  Map<String, String> keys,
) {
  return Wrapper.execute(() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    final rows = budgets
        .where((budget) {
          final spent = double.tryParse(budget.amountSpent ?? '0') ?? 0;
          return budget.id != null && keys.containsKey(budget.id) && spent > 0;
        })
        .map((budget) => {
              'id': _uuid.v4(),
              'budget_id': int.tryParse(budget.id!),
              'user_id': userId,
              'category': budget.category?.id,
              'amount': budget.amount,
              'amount_spent': budget.amountSpent,
              'period_month': keys[budget.id],
            })
        .toList();
    if (rows.isNotEmpty) await client.from('budget_history').insert(rows);
  });
}

Future<void> resetBudgetsSpent(List<String> budgetIds) {
  return Wrapper.execute(() async {
    if (budgetIds.isEmpty) return;
    final ids = budgetIds.map(int.parse).toList();
    await Supabase.instance.client.from('budgets').update({
      'amount_spent': '0',
      'last_reset_at': DateTime.now().toUtc().toIso8601String(),
    }).inFilter('id', ids);
  });
}

Future<bool> checkAndResetBudgetsByPeriod(List<Budget> budgets) async {
  final now = DateTime.now();
  final due = <Budget>[];
  final keys = <String, String>{};
  for (final budget in budgets) {
    if (budget.id == null) continue;
    final period = normalizeBudgetPeriod(budget.period);
    final resetAt = budget.lastResetAt ?? budget.createdAt ?? now;
    if (_isResetDue(now, resetAt, period)) {
      due.add(budget);
      keys[budget.id!] = _periodKey(resetAt, period);
    }
  }
  if (due.isEmpty) return false;
  await archiveBudgetsToHistory(due, keys);
  await resetBudgetsSpent(due.map((budget) => budget.id!).toList());
  debugPrint('Budget reset completed for ${due.length} budgets');
  return true;
}

String getPeriodMonthString(DateTime date) => _periodKey(date, 'monthly');

Future<void> deleteBudgetHistory(String id) {
  return Wrapper.execute(
    () => Supabase.instance.client.from('budget_history').delete().eq('id', id),
  );
}
