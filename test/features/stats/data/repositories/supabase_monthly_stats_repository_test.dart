import 'package:budgets/features/stats/data/repositories/supabase_monthly_stats_repository.dart';
import 'package:budgets/features/stats/data/services/monthly_stats_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMonthlyStatsService extends Mock implements MonthlyStatsService {}

void main() {
  test('builds monthly totals, daily spending, and category ranking', () async {
    final service = _MockMonthlyStatsService();
    final repository = SupabaseMonthlyStatsRepository(service);
    when(() => service.transactionsForMonth(DateTime(2026, 7))).thenAnswer(
      (_) async => [
        _row(50000, 'income', '2026-07-02', 'Salary', '💼'),
        _row(3000, 'expense', '2026-07-02', 'Food', '🍔'),
        _row(7000, 'expense', '2026-07-03', 'Food', '🍔'),
        _row(5000, 'expense', '2026-07-03', 'Transport', '🚕'),
      ],
    );
    when(() => service.transactionsForMonth(DateTime(2026, 6))).thenAnswer(
      (_) async => [
        _row(10000, 'expense', '2026-06-03', 'Food', '🍔'),
      ],
    );

    final result = await repository.statsForMonth(DateTime(2026, 7));

    expect(result.income, 50000);
    expect(result.expenses, 15000);
    expect(result.balance, 35000);
    expect(result.transactionCount, 4);
    expect(result.largestExpense, 7000);
    expect(result.dailyExpenses[1], 3000);
    expect(result.dailyExpenses[2], 12000);
    expect(result.expenseCategories.first.name, 'Food');
    expect(result.expenseCategories.first.amount, 10000);
    expect(result.expenseChange, 50);
  });
}

Map<String, dynamic> _row(
  int amount,
  String type,
  String date,
  String category,
  String emoji,
) {
  return {
    'amount': amount,
    'transaction_type': type,
    'date': '${date}T12:00:00Z',
    'currency_code': 'MGA',
    'categories': {'name': category, 'emoji': emoji},
  };
}
