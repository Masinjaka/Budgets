import 'package:budgets/features/stats/data/services/monthly_stats_service.dart';
import 'package:budgets/features/stats/domain/models/monthly_stats.dart';
import 'package:budgets/features/stats/domain/repositories/monthly_stats_repository.dart';

class SupabaseMonthlyStatsRepository implements MonthlyStatsRepository {
  const SupabaseMonthlyStatsRepository(this._service);

  final MonthlyStatsService _service;

  @override
  Future<MonthlyStats> statsForMonth(DateTime month) async {
    final previous = DateTime(month.year, month.month - 1);
    final results = await Future.wait([
      _service.transactionsForMonth(month),
      _service.transactionsForMonth(previous),
    ]);
    final rows = results[0];
    final days = DateTime(month.year, month.month + 1, 0).day;
    final daily = List<int>.filled(days, 0);
    final categoryTotals = <String, int>{};
    final categoryEmoji = <String, String>{};
    var income = 0;
    var expenses = 0;
    var largest = 0;
    var currencyCode = 'MGA';

    for (final row in rows) {
      final amount = (row['amount'] as num? ?? 0).round();
      currencyCode = (row['currency_code'] as String?) ?? currencyCode;
      if (row['transaction_type'] == 'income') {
        income += amount;
        continue;
      }
      expenses += amount;
      if (amount > largest) largest = amount;
      final date = DateTime.parse(row['date'] as String).toLocal();
      if (date.day <= daily.length) daily[date.day - 1] += amount;
      final category = _record(row['categories']);
      final name = (category['name'] as String?) ?? 'Other';
      categoryTotals.update(
        name,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
      categoryEmoji[name] = (category['emoji'] as String?) ?? '🧾';
    }

    final breakdown = categoryTotals.entries
        .map(
          (entry) => CategoryStat(
            name: entry.key,
            emoji: categoryEmoji[entry.key]!,
            amount: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final previousExpenses = results[1]
        .where((row) => row['transaction_type'] == 'expense')
        .fold<int>(0, (total, row) => total + (row['amount'] as num).round());

    return MonthlyStats(
      income: income,
      expenses: expenses,
      transactionCount: rows.length,
      largestExpense: largest,
      previousExpenses: previousExpenses,
      expenseCategories: List.unmodifiable(breakdown),
      dailyExpenses: List.unmodifiable(daily),
      currencyCode: currencyCode,
    );
  }

  Map<String, dynamic> _record(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}
