import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppChartData {
  /// Returns a list of [BarChartGroupData] suitable for [BarChart] with separate bars for expenses and income.
  static List<BarChartGroupData> getWeeklyExpenseIncomeData(
      List<TransactionModel> transactions) {
    final now = DateTime.now();
    // Create a list of the last 7 days, normalized to the start of each day.
    List<DateTime> last7Days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DateTime(date.year, date.month, date.day);
    });

    // Maps to store daily totals for expenses and income
    Map<int, double> dailyExpenses = {for (int i = 0; i < 7; i++) i: 0.0};
    Map<int, double> dailyIncome = {for (int i = 0; i < 7; i++) i: 0.0};

    // Aggregate transactions by type
    for (var transaction in transactions) {
      final transactionDay = DateTime(transaction.date!.year,
          transaction.date!.month, transaction.date!.day);

      final dayIndex = last7Days.indexOf(transactionDay);

      if (dayIndex != -1) {
        if (transaction.transactionType == TransactionType.expense) {
          dailyExpenses[dayIndex] =
              (dailyExpenses[dayIndex] ?? 0.0) + (transaction.amount ?? 0.0);
        } else if (transaction.transactionType == TransactionType.income) {
          dailyIncome[dayIndex] =
              (dailyIncome[dayIndex] ?? 0.0) + (transaction.amount ?? 0.0);
        }
      }
    }

    // Convert aggregated data into BarChartGroupData with two bars per day
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          // Red bar for expenses
          BarChartRodData(
            toY: dailyExpenses[index] ?? 0.0,
            color: Colors.redAccent,
            width: 4.5.w,
            borderRadius: BorderRadius.circular(3.w),
          ),
          // Green bar for income
          BarChartRodData(
            toY: dailyIncome[index] ?? 0.0,
            color: Colors.greenAccent,
            width: 4.5.w,
            borderRadius: BorderRadius.circular(3.w),
          ),
        ],
      );
    });
  }

  /// Returns a list of [BarChartGroupData] suitable for [BarChart] - legacy method for expenses only.
  static List<BarChartGroupData> getWeeklyData(
      List<TransactionModel> expenses) {
    final now = DateTime.now();
    // Create a list of the last 7 days, normalized to the start of each day.
    // This helps in consistent comparison regardless of time.
    List<DateTime> last7Days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DateTime(
          date.year, date.month, date.day); // Normalize to start of day
    });

    // Map to store daily totals, using the day's index (0-6) as key.
    Map<int, double> dailyTotals = {for (int i = 0; i < 7; i++) i: 0.0};

    // Aggregate expenses.
    for (var expense in expenses) {
      // Normalize the expense date to the start of its day.
      final expenseDay =
          DateTime(expense.date!.year, expense.date!.month, expense.date!.day);

      // Find the index of the matching day in our last7Days list.
      // If expenseDay matches last7Days[0], index is 0.
      // If expenseDay matches last7Days[6] (today), index is 6.
      final dayIndex = last7Days.indexOf(expenseDay);

      if (dayIndex != -1) {
        // If the expense falls within the last 7 days
        dailyTotals[dayIndex] =
            (dailyTotals[dayIndex] ?? 0.0) + expense.amount!;
      }
    }

    // Convert aggregated daily data into BarChartGroupData.
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index, // X-axis value representing the day index (0-6).
        barRods: [
          BarChartRodData(
            toY: dailyTotals[index] ??
                0.0, // Y-axis value representing the expense amount.
            color: Colors.greenAccent,
            width: 6.w,
            borderRadius: BorderRadius.circular(5.w),
          ),
        ],
      );
    });
  }

  // Get monthly data
  static List<FlSpot> getMonthlyData(List<TransactionModel> expenses) {
    final now = DateTime.now();
    final currentYear = now.year;

    // Map to store monthly totals: month number (1-12) -> total amount.
    Map<int, double> monthlyTotals = {
      for (int i = 1; i <= 12; i++) i: 0.0 // Initialize all 12 months to 0
    };

    // Aggregate expenses into monthly totals, only for the current year.
    for (var expense in expenses) {
      if (expense.date!.year == currentYear) {
        monthlyTotals[expense.date!.month] =
            (monthlyTotals[expense.date!.month] ?? 0.0) + expense.amount!;
      }
    }

    // Convert aggregated monthly data into FlSpot objects for the line chart.
    // Ensure all 12 months are represented, even if their total is 0.
    List<FlSpot> spots = [];
    for (int i = 1; i <= 12; i++) {
      // Iterate from January (1) to December (12)
      spots.add(FlSpot((i - 1).toDouble(), monthlyTotals[i] ?? 0.0));
    }
    return spots;
  }

  // Monthly data
  static List<FlSpot> getYearlyData(List<TransactionModel> expenses) {
    final now = DateTime.now();
    // Get the current year.
    final currentYear = now.year;

    // Map to store yearly totals: year -> total amount.
    Map<int, double> yearlyTotals = {};

    // Initialize totals for the last 3 years (current year and two previous).
    for (int i = 0; i < 3; i++) {
      yearlyTotals[currentYear - i] = 0.0;
    }

    // Aggregate expenses by year, considering only the last 3 years.
    for (var expense in expenses) {
      final year = expense.date!.year;
      if (year >= currentYear - 2 && year <= currentYear) {
        // Filter for last 3 years
        yearlyTotals[year] = (yearlyTotals[year] ?? 0.0) + expense.amount!;
      }
    }

    // Sort the years to ensure chronological order for the chart.
    final sortedYears = yearlyTotals.keys.toList()..sort();

    // Convert aggregated yearly data into FlSpot objects for the line chart.
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedYears.length; i++) {
      spots.add(FlSpot(i.toDouble(), yearlyTotals[sortedYears[i]] ?? 0.0));
    }
    return spots;
  }

  /// Returns bar chart data for hourly transactions in the current day (24 hours)
  static List<BarChartGroupData> getDailyHourlyData(
      List<TransactionModel> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Maps to store hourly totals for expenses and income
    Map<int, double> hourlyExpenses = {for (int i = 0; i < 24; i++) i: 0.0};
    Map<int, double> hourlyIncome = {for (int i = 0; i < 24; i++) i: 0.0};

    // Aggregate transactions by hour for today only
    for (var transaction in transactions) {
      final transactionDay = DateTime(transaction.date!.year,
          transaction.date!.month, transaction.date!.day);

      if (transactionDay.isAtSameMomentAs(today)) {
        final hour = transaction.date!.hour;
        if (transaction.transactionType == TransactionType.expense) {
          hourlyExpenses[hour] =
              (hourlyExpenses[hour] ?? 0.0) + (transaction.amount ?? 0.0);
        } else if (transaction.transactionType == TransactionType.income) {
          hourlyIncome[hour] =
              (hourlyIncome[hour] ?? 0.0) + (transaction.amount ?? 0.0);
        }
      }
    }

    // Convert aggregated data into BarChartGroupData
    return List.generate(24, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: hourlyExpenses[index] ?? 0.0,
            color: Colors.redAccent,
            width: 4.5.w,
            borderRadius: BorderRadius.circular(3.w),
          ),
          BarChartRodData(
            toY: hourlyIncome[index] ?? 0.0,
            color: Colors.greenAccent,
            width: 4.5.w,
            borderRadius: BorderRadius.circular(3.w),
          ),
        ],
      );
    });
  }

  /// Returns bar chart data for weekly transactions (7 days, today and 6 days before)
  static List<BarChartGroupData> getWeeklyDailyData(
      List<TransactionModel> transactions) {
    // This is the same as getWeeklyExpenseIncomeData
    return getWeeklyExpenseIncomeData(transactions);
  }

  /// Returns bar chart data for monthly transactions (4 weeks from current week backwards)
  static List<BarChartGroupData> getMonthlyWeeklyData(
      List<TransactionModel> transactions) {
    final now = DateTime.now();

    // Calculate the start of each week (4 weeks back from current week)
    List<DateTime> weekStarts = [];
    for (int i = 3; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      weekStarts.add(DateTime(weekStart.year, weekStart.month, weekStart.day));
    }

    // Maps to store weekly totals
    Map<int, double> weeklyExpenses = {for (int i = 0; i < 4; i++) i: 0.0};
    Map<int, double> weeklyIncome = {for (int i = 0; i < 4; i++) i: 0.0};

    // Aggregate transactions by week
    for (var transaction in transactions) {
      final transactionDay = DateTime(transaction.date!.year,
          transaction.date!.month, transaction.date!.day);

      for (int i = 0; i < 4; i++) {
        final weekStart = weekStarts[i];
        final weekEnd = weekStart.add(const Duration(days: 7));

        if (transactionDay
                .isAfter(weekStart.subtract(const Duration(days: 1))) &&
            transactionDay.isBefore(weekEnd)) {
          if (transaction.transactionType == TransactionType.expense) {
            weeklyExpenses[i] =
                (weeklyExpenses[i] ?? 0.0) + (transaction.amount ?? 0.0);
          } else if (transaction.transactionType == TransactionType.income) {
            weeklyIncome[i] =
                (weeklyIncome[i] ?? 0.0) + (transaction.amount ?? 0.0);
          }
          break;
        }
      }
    }

    // Convert aggregated data into BarChartGroupData
    return List.generate(4, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyExpenses[index] ?? 0.0,
            color: Colors.redAccent,
            width: 4.5.w,
            borderRadius: BorderRadius.circular(3.w),
          ),
          BarChartRodData(
            toY: weeklyIncome[index] ?? 0.0,
            color: Colors.greenAccent,
            width: 4.5.w,
            borderRadius: BorderRadius.circular(3.w),
          ),
        ],
      );
    });
  }

  /// Returns bar chart data for yearly transactions (12 months from current month backwards)
  static List<BarChartGroupData> getYearlyMonthlyData(
      List<TransactionModel> transactions) {
    final now = DateTime.now();

    // Create list of last 12 months
    List<DateTime> last12Months = [];
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      last12Months.add(month);
    }

    // Maps to store monthly totals
    Map<int, double> monthlyExpenses = {for (int i = 0; i < 12; i++) i: 0.0};
    Map<int, double> monthlyIncome = {for (int i = 0; i < 12; i++) i: 0.0};

    // Aggregate transactions by month
    for (var transaction in transactions) {
      final transactionMonth =
          DateTime(transaction.date!.year, transaction.date!.month, 1);

      final monthIndex = last12Months.indexOf(transactionMonth);

      if (monthIndex != -1) {
        if (transaction.transactionType == TransactionType.expense) {
          monthlyExpenses[monthIndex] = (monthlyExpenses[monthIndex] ?? 0.0) +
              (transaction.amount ?? 0.0);
        } else if (transaction.transactionType == TransactionType.income) {
          monthlyIncome[monthIndex] =
              (monthlyIncome[monthIndex] ?? 0.0) + (transaction.amount ?? 0.0);
        }
      }
    }

    // Convert aggregated data into BarChartGroupData
    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: monthlyExpenses[index] ?? 0.0,
            color: Colors.redAccent,
            width: 4.5.w,
            borderRadius: BorderRadius.circular(3.w),
          ),
          BarChartRodData(
            toY: monthlyIncome[index] ?? 0.0,
            color: Colors.greenAccent,
            width: 4.5.w,
            borderRadius: BorderRadius.circular(3.w),
          ),
        ],
      );
    });
  }

  /// Returns pie chart data for category breakdown
  static Map<String, dynamic> getCategoryPieData(
      List<TransactionModel> transactions, TransactionType type) {
    Map<String, double> categoryTotals = {};
    Map<String, String> categoryColors = {};
    Map<String, String> categoryEmojis = {};

    // Aggregate transactions by category
    for (var transaction in transactions) {
      if (transaction.transactionType == type && transaction.category != null) {
        final categoryName = transaction.category!.name ?? 'Unknown';
        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0.0) + (transaction.amount ?? 0.0);
        categoryColors[categoryName] =
            transaction.category!.color ?? 'FF10B981';
        categoryEmojis[categoryName] = transaction.category!.emoji ?? '❓';
      }
    }

    return {
      'totals': categoryTotals,
      'colors': categoryColors,
      'emojis': categoryEmojis,
    };
  }
}
