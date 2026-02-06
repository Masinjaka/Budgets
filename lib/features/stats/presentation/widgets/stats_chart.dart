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
    final incomeBarColor =
        (textColor ?? Theme.of(context).colorScheme.onSurface)
            .withValues(alpha: 0.85);

    // Softer accent colors for the chart bars
    const expenseColor = Color(0xFFEF9A9A); // Lighter red accent

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
        borderRadius: BorderRadius.circular(6.w),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final perDayWidth = constraints.maxWidth / 7;
                final chartWidth = perDayWidth * daysInMonth;
                final barsSpace = perDayWidth * 0.1;
                final barWidth = (perDayWidth - barsSpace) / 2;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.start,
                        groupsSpace: 0,
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
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt() + 1}',
                              style: TextStyle(
                                color: textColor?.withValues(alpha: 0.7),
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            );
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
                    minY: 0,
                    maxY: maxValue,
                        barGroups: List.generate(daysInMonth, (index) {
                          return BarChartGroupData(
                            x: index,
                            barsSpace: barsSpace,
                            barRods: [
                              BarChartRodData(
                                toY: convertedExpenseData[index],
                                color: expenseColor,
                                width: barWidth,
                                borderRadius:
                                    BorderRadius.circular(perDayWidth * 0.3),
                              ),
                              BarChartRodData(
                                toY: convertedIncomeData[index],
                                color: incomeBarColor,
                                width: barWidth,
                                borderRadius:
                                    BorderRadius.circular(perDayWidth * 0.3),
                              ),
                            ],
                          );
                        }),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) =>
                                Theme.of(context).colorScheme.surface,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final isExpense = rodIndex == 0;
                              return BarTooltipItem(
                                formatAmountWithCurrency(rod.toY, currencyCode),
                                TextStyle(
                                  color: isExpense
                                      ? expenseColor
                                      : incomeBarColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
