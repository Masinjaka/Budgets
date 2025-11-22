import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Widget buildLineChart(
    List<FlSpot> spots, String periodType, List<TransactionModel> expenses) {
  final NumberFormat formatter = NumberFormat.compact();
  return Expanded(
    child: LineChart(
      LineChartData(
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
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 2.h,
              interval: periodType == 'Monthly' ? 1 : null,
              getTitlesWidget: (value, meta) {
                String text = '';
                if (periodType == 'Weekly') {
                  final monthNames = DateFormat()
                      .dateSymbols
                      .SHORTMONTHS; // Get short month names
                  if (value.toInt() >= 0 && value.toInt() < monthNames.length) {
                    text = monthNames[value.toInt()];
                  }
                } else if (periodType == 'Monthly') {
                  // Display year for yearly chart.
                  final currentYear = DateTime.now().year;
                  final years = List.generate(
                      3, (index) => currentYear - (2 - index)).toList()
                    ..sort();
                  if (value.toInt() < years.length) {
                    text = years[value.toInt()].toString();
                  }
                }
                return SideTitleWidget(
                  space: 8.0,
                  meta: meta,
                  child: Text(text, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // Display dollar amounts on the left Y-axis.
                  return Text(formatter.format(value.toInt()),
                      style: const TextStyle(fontSize: 10));
                },
                reservedSize: 4.h,
                maxIncluded: false),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: spots.isNotEmpty
            ? spots.last.x
            : 0, // Max X based on the last data point.
        minY: 0,
        maxY: spots.isNotEmpty
            ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2
            : 100, // Max Y with 20% buffer.
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true, // Smooth curve for the line.
            curveSmoothness: 0.2,
            color: Colors.greenAccent,
            barWidth: 1.w,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
            ), // Show dots at each data point.
            belowBarData: BarAreaData(show: true), // No area below the line.
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300), // Optional
      curve: Curves.linear,
    ),
  );
}
