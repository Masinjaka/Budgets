import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsChart extends ConsumerWidget {
  final List<double> expenseData;
  final List<double> incomeData;
  final int daysInMonth;

  const StatsChart({
    super.key,
    required this.expenseData,
    required this.incomeData,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;
    final convertedExpenseData =
        expenseData.map((value) => value * rate).toList();
    final convertedIncomeData =
        incomeData.map((value) => value * rate).toList();
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    // Softer accent colors for the chart lines
    const expenseColor = Color(0xFFEF9A9A); // Lighter red accent
    const incomeColor = Color(0xFFA5D6A7); // Lighter green accent

    // Calculate max value for y-axis
    double maxValue = 0;
    for (final value in convertedExpenseData) {
      if (value > maxValue) maxValue = value;
    }
    for (final value in convertedIncomeData) {
      if (value > maxValue) maxValue = value;
    }
    // Add some padding to max value
    maxValue = maxValue == 0 ? 100 : maxValue * 1.2;

    return Container(
      height: 25.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Évolution',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: textColor?.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: textColor?.withValues(alpha: 0.1) ??
                          Colors.grey.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (daysInMonth / 6).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        if (value % (daysInMonth / 6).ceil() == 0 ||
                            value == daysInMonth - 1) {
                          return Text(
                            '${value.toInt() + 1}',
                            style: TextStyle(
                              color: textColor?.withValues(alpha: 0.5),
                              fontSize: 10.sp,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (daysInMonth - 1).toDouble(),
                minY: 0,
                maxY: maxValue,
                lineBarsData: [
                  // Expense line
                  LineChartBarData(
                    spots: _createSpots(convertedExpenseData),
                    isCurved: true,
                    color: expenseColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: expenseColor.withValues(alpha: 0.1),
                    ),
                  ),
                  // Income line
                  LineChartBarData(
                    spots: _createSpots(convertedIncomeData),
                    isCurved: true,
                    color: incomeColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: incomeColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) =>
                        Theme.of(context).colorScheme.surface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isExpense = spot.barIndex == 0;
                        return LineTooltipItem(
                          formatAmountWithCurrency(spot.y, currencyCode),
                          TextStyle(
                            color: isExpense ? expenseColor : incomeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _createSpots(List<double> data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }
    return spots;
  }
}
