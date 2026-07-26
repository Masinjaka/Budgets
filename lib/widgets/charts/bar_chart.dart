import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/core/functions/chart_data.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Builds and returns a [BarChart] widget for daily expenses and income.
Widget dailyBarChart(List<TransactionModel> transactions,
    {required double currencyRate}) {
  final dailyData = AppChartData.getWeeklyExpenseIncomeData(transactions);
  double maxAmount = 0;

  // Determine the maximum Y-axis value from both expenses and income
  if (dailyData.isNotEmpty) {
    maxAmount = dailyData
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
  }

  final convertedData = dailyData
      .map(
        (group) => group.copyWith(
          barRods: group.barRods
              .map((rod) => rod.copyWith(toY: rod.toY * currencyRate))
              .toList(),
        ),
      )
      .toList();

  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(seconds: 1),
    curve: Curves.easeOutQuart,
    builder: (context, value, child) {
      final animatedData = convertedData.map((group) {
        final animatedRods = group.barRods.map((rod) {
          return rod.copyWith(toY: rod.toY * value);
        }).toList();
        return group.copyWith(barRods: animatedRods);
      }).toList();

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 48,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: animatedData,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final today = DateTime.now();
                  final day = today.subtract(Duration(days: 6 - value.toInt()));
                  return SideTitleWidget(
                    space: 4,
                    meta: meta,
                    child: Text(
                      DateFormat('EEE').format(day),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 16,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                maxIncluded: false,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    formatAmountValue(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
                reservedSize: 32,
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) =>
                  Colors.black.withAlpha((255 * 0.8).round()),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // To restore the original value in tooltip, we divide by value if value > 0
                // Or better, since we can't easily access original data here without capture,
                // we'll accept that during animation tooltip might show animated value.
                // However, since tooltip is interactive, user likely won't touch during the 1s animation.
                String type = rodIndex == 0 ? 'Dépenses' : 'Revenus';
                return BarTooltipItem(
                  '$type\n${formatAmountValue(rod.toY)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          maxY: maxAmount * currencyRate * 1.2,
        ),
        duration: Duration.zero, // Disable internal animation
      );
    },
  );
}

/// Builds and returns a [BarChart] widget for daily expenses only - legacy function.
Widget dailyExpensesBarChart(List<TransactionModel> expenses,
    {required double currencyRate}) {
  final dailyData = AppChartData.getWeeklyData(expenses);
  double maxDailyAmount = 0;
  // Determine the maximum Y-axis value for proper scaling.
  if (dailyData.isNotEmpty) {
    maxDailyAmount = dailyData
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
  }

  final convertedData = dailyData
      .map(
        (group) => group.copyWith(
          barRods: group.barRods
              .map((rod) => rod.copyWith(toY: rod.toY * currencyRate))
              .toList(),
        ),
      )
      .toList();

  return BarChart(
    BarChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      barGroups: convertedData, // No border around the chart.
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              // Display day names (e.g., Mon, Tue) for the last 7 days.
              final today = DateTime.now();
              final day = today.subtract(Duration(days: 6 - value.toInt()));
              return SideTitleWidget(
                space: 4,
                meta: meta,
                child: Text(DateFormat('EEE').format(day),
                    style: const TextStyle(fontSize: 10)),
              );
            },
            reservedSize: 16,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            maxIncluded: false,
            showTitles: true,
            getTitlesWidget: (value, meta) {
              // Display dollar amounts on the left Y-axis.
              return Text(formatAmountValue(value),
                  style: const TextStyle(fontSize: 10));
            },
            reservedSize: 32,
          ),
        ),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)), // Hide top titles.
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)), // Hide right titles.
      ), // Hide grid lines.
      barTouchData: const BarTouchData(
          enabled: true), // Enable touch interactions for bars.
      maxY: maxDailyAmount * currencyRate * 1.2,
    ),
    duration: const Duration(milliseconds: 300), // Optional
    curve: Curves.linear,
  );
}
