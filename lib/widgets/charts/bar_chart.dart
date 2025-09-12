import 'package:budgets/model/expense_model.dart';
import 'package:budgets/utils/chart_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Builds and returns a [BarChart] widget for daily expenses.
Widget dailyBarChart(List<Expense> expenses) {
  final dailyData = AppChartData.getWeeklyData(expenses);
  double maxDailyAmount = 0;
  // Determine the maximum Y-axis value for proper scaling.
  if (dailyData.isNotEmpty) {
    maxDailyAmount = dailyData
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
  }

  final NumberFormat formatter = NumberFormat.compact();

  return Expanded(
    child: BarChart(
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
        barGroups: dailyData,// No border around the chart.
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
              reservedSize: 2.h,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              maxIncluded: false,
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Display dollar amounts on the left Y-axis.
                return Text(formatter.format(value.toInt()),
                    style: const TextStyle(fontSize: 10));
              },
              reservedSize: 4.h,
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)), // Hide top titles.
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)), // Hide right titles.
        ),// Hide grid lines.
        barTouchData: const BarTouchData(
            enabled: true), // Enable touch interactions for bars.
        maxY: maxDailyAmount * 1.2, // Set max Y-axis with a 20% buffer.
      ),
      duration: const Duration(milliseconds: 300), // Optional
      curve: Curves.linear,
    ),
  );
}
