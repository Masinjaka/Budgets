import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/core/functions/chart_data.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Builds bar chart for daily hourly view (24 hours)
Widget dailyHourlyBarChart(List<TransactionModel> transactions) {
  final hourlyData = AppChartData.getDailyHourlyData(transactions);
  double maxAmount = 0;

  if (hourlyData.isNotEmpty) {
    maxAmount = hourlyData
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
  }

  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(seconds: 1),
    curve: Curves.easeOutQuart,
    builder: (context, value, child) {
      final animatedData = hourlyData.map((group) {
        final animatedRods = group.barRods.map((rod) {
          return rod.copyWith(toY: rod.toY * value);
        }).toList();
        return group.copyWith(barRods: animatedRods);
      }).toList();

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 2.w,
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
                  // Show only every 3rd hour to avoid crowding
                  if (value.toInt() % 3 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    space: 4,
                    meta: meta,
                    child: Text(
                      '${value.toInt()}h',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 2.h,
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
                reservedSize: 4.h,
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
          maxY: maxAmount * 1.2,
        ),
        duration: Duration.zero,
      );
    },
  );
}

/// Builds bar chart for monthly weekly view (4 weeks)
Widget monthlyWeeklyBarChart(List<TransactionModel> transactions) {
  final weeklyData = AppChartData.getMonthlyWeeklyData(transactions);
  double maxAmount = 0;

  if (weeklyData.isNotEmpty) {
    maxAmount = weeklyData
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
  }

  final now = DateTime.now();

  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(seconds: 1),
    curve: Curves.easeOutQuart,
    builder: (context, value, child) {
      final animatedData = weeklyData.map((group) {
        final animatedRods = group.barRods.map((rod) {
          return rod.copyWith(toY: rod.toY * value);
        }).toList();
        return group.copyWith(barRods: animatedRods);
      }).toList();

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 12.w,
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
                  final weekIndex = value.toInt();
                  // Calculate date range for the week
                  // weekIndex 3 is current week, 0 is 3 weeks ago
                  final weeksBack = 3 - weekIndex;
                  // Start of the week (Monday)
                  final weekStart = now.subtract(
                      Duration(days: now.weekday - 1 + (weeksBack * 7)));
                  final weekEnd = weekStart.add(const Duration(days: 6));

                  return SideTitleWidget(
                    space: 4,
                    meta: meta,
                    child: Text(
                      '${weekStart.day}-${weekEnd.day}',
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                },
                reservedSize: 2.h,
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
                reservedSize: 4.h,
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
          maxY: maxAmount * 1.2,
        ),
        duration: Duration.zero,
      );
    },
  );
}

/// Builds bar chart for yearly monthly view (12 months)
Widget yearlyMonthlyBarChart(List<TransactionModel> transactions) {
  final monthlyData = AppChartData.getYearlyMonthlyData(transactions);
  double maxAmount = 0;

  if (monthlyData.isNotEmpty) {
    maxAmount = monthlyData
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
  }

  final now = DateTime.now();

  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(seconds: 1),
    curve: Curves.easeOutQuart,
    builder: (context, value, child) {
      final animatedData = monthlyData.map((group) {
        final animatedRods = group.barRods.map((rod) {
          return rod.copyWith(toY: rod.toY * value);
        }).toList();
        return group.copyWith(barRods: animatedRods);
      }).toList();

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 2.w,
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
                  final monthIndex = value.toInt();
                  final month =
                      DateTime(now.year, now.month - (11 - monthIndex), 1);
                  return SideTitleWidget(
                    space: 4,
                    meta: meta,
                    child: Text(
                      DateFormat('MMM').format(month),
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                },
                reservedSize: 2.h,
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
                reservedSize: 4.h,
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
          maxY: maxAmount * 1.2,
        ),
        duration: Duration.zero,
      );
    },
  );
}
