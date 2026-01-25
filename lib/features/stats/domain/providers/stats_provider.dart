import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_provider.g.dart';

/// Data class for balance information
class BalanceData {
  final double allTimeBalance;
  final double currentPeriodBalance;
  final double previousPeriodBalance;
  final double changeAmount;
  final double changePercentage;
  final bool isPositiveChange;

  BalanceData({
    required this.allTimeBalance,
    required this.currentPeriodBalance,
    required this.previousPeriodBalance,
    required this.changeAmount,
    required this.changePercentage,
    required this.isPositiveChange,
  });
}

/// Data class for period statistics
class PeriodStats {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomeByCategory;

  PeriodStats({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
    required this.expensesByCategory,
    required this.incomeByCategory,
  });
}

/// Provider to calculate all-time balance
@riverpod
Future<double> allTimeBalance(Ref ref) async {
  final transactions = await ref.watch(transactionsProvider.future);

  double totalIncome = 0.0;
  double totalExpenses = 0.0;

  for (final transaction in transactions) {
    final amount = transaction.amount ?? 0.0;
    if (transaction.transactionType == TransactionType.income) {
      totalIncome += amount;
    } else if (transaction.transactionType == TransactionType.expense) {
      totalExpenses += amount;
    }
  }

  return totalIncome - totalExpenses;
}

/// Provider to calculate balance for a specific date range
@riverpod
Future<PeriodStats> periodStats(
    Ref ref, DateTime startDate, DateTime endDate) async {
  final transactions = await ref.watch(transactionsProvider.future);

  // Normalize dates to midnight for comparison
  final normalizedStart =
      DateTime(startDate.year, startDate.month, startDate.day);
  final normalizedEnd =
      DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  int transactionCount = 0;
  final Map<String, double> expensesByCategory = {};
  final Map<String, double> incomeByCategory = {};

  for (final transaction in transactions) {
    if (transaction.date == null) continue;

    final transactionDate = transaction.date!;

    if (transactionDate
            .isAfter(normalizedStart.subtract(const Duration(seconds: 1))) &&
        transactionDate
            .isBefore(normalizedEnd.add(const Duration(seconds: 1)))) {
      final amount = transaction.amount ?? 0.0;
      final categoryName = transaction.category?.name ?? 'Autre';
      transactionCount++;

      if (transaction.transactionType == TransactionType.income) {
        totalIncome += amount;
        incomeByCategory[categoryName] =
            (incomeByCategory[categoryName] ?? 0.0) + amount;
      } else if (transaction.transactionType == TransactionType.expense) {
        totalExpenses += amount;
        expensesByCategory[categoryName] =
            (expensesByCategory[categoryName] ?? 0.0) + amount;
      }
    }
  }

  return PeriodStats(
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    balance: totalIncome - totalExpenses,
    transactionCount: transactionCount,
    expensesByCategory: expensesByCategory,
    incomeByCategory: incomeByCategory,
  );
}

/// Provider to compare two periods and get comprehensive balance data
@riverpod
Future<BalanceData> balanceComparison(
  Ref ref,
  DateTime currentStart,
  DateTime currentEnd,
  DateTime previousStart,
  DateTime previousEnd,
) async {
  final allTime = await ref.watch(allTimeBalanceProvider.future);
  final currentPeriod =
      await ref.watch(periodStatsProvider(currentStart, currentEnd).future);
  final previousPeriod =
      await ref.watch(periodStatsProvider(previousStart, previousEnd).future);

  final changeAmount = currentPeriod.balance - previousPeriod.balance;
  final changePercentage = previousPeriod.balance != 0
      ? (changeAmount / previousPeriod.balance.abs()) * 100
      : 0.0;

  return BalanceData(
    allTimeBalance: allTime,
    currentPeriodBalance: currentPeriod.balance,
    previousPeriodBalance: previousPeriod.balance,
    changeAmount: changeAmount,
    changePercentage: changePercentage,
    isPositiveChange: changeAmount >= 0,
  );
}
