import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsChart extends ConsumerStatefulWidget {
  final List<double> expenseData;
  final List<double> incomeData;
  final int daysInMonth;
  final DateTime selectedMonth;

  const StatsChart({
    super.key,
    required this.expenseData,
    required this.incomeData,
    required this.daysInMonth,
    required this.selectedMonth,
  });

  @override
  ConsumerState<StatsChart> createState() => _StatsChartState();
}

class _StatsChartState extends ConsumerState<StatsChart> {
  late int _selectedWeekIndex;

  int get _totalWeeks => ((widget.daysInMonth - 1) ~/ 7) + 1;

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return now.year == widget.selectedMonth.year &&
        now.month == widget.selectedMonth.month;
  }

  int get _currentWeekIndex {
    if (!_isCurrentMonth) return 0;
    return (DateTime.now().day - 1) ~/ 7;
  }

  // 0-indexed day range for a given week
  int _weekStartDay(int weekIndex) => weekIndex * 7;
  int _weekEndDay(int weekIndex) =>
      ((weekIndex + 1) * 7 - 1).clamp(0, widget.daysInMonth - 1);

  String _rangeLabel(int weekIndex) {
    final start = weekIndex * 7 + 1;
    final end = ((weekIndex + 1) * 7).clamp(1, widget.daysInMonth);
    return '$start–$end';
  }

  List<int> get _dropdownWeeks {
    if (!_isCurrentMonth) {
      return List.generate(_totalWeeks, (i) => i);
    }
    final weeks = <int>[];
    for (final offset in [-1, 0]) {
      final w = _currentWeekIndex + offset;
      if (w >= 0 && w < _totalWeeks) weeks.add(w);
    }
    return weeks;
  }

  String _weekLabel(int weekIndex) {
    if (!_isCurrentMonth) return _rangeLabel(weekIndex);
    switch (weekIndex - _currentWeekIndex) {
      case -1:
        return 'Semaine passée';
      case 0:
        return 'Cette semaine';
      default:
        return _rangeLabel(weekIndex);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedWeekIndex = _currentWeekIndex;
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;

    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    const expenseColor = Color(0xFFEF5350);
    final incomeColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.grey.shade500;

    final startDay = _weekStartDay(_selectedWeekIndex);
    final endDay = _weekEndDay(_selectedWeekIndex);
    final weekLength = endDay - startDay + 1;

    // Slice data to selected week
    final expenseSlice = widget.expenseData
        .sublist(startDay, endDay + 1)
        .map((v) => v * rate)
        .toList();
    final incomeSlice = widget.incomeData
        .sublist(startDay, endDay + 1)
        .map((v) => v * rate)
        .toList();

    double maxValue = 0;
    for (final v in [...expenseSlice, ...incomeSlice]) {
      if (v > maxValue) maxValue = v;
    }
    maxValue = maxValue == 0 ? 100 : maxValue * 1.2;

    List<FlSpot> toSpots(List<double> data) =>
        List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i]));

    final dropdownWeeks = _dropdownWeeks;

    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Évolution',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor?.withValues(alpha: 0.7),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4.8),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: textColor?.withValues(alpha: 0.08) ??
                        Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedWeekIndex,
                    isDense: true,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor?.withValues(alpha: 0.8),
                    ),
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: textColor?.withValues(alpha: 0.5),
                    ),
                    items: dropdownWeeks
                        .map(
                          (w) => DropdownMenuItem(
                            value: w,
                            child: Text(_weekLabel(w)),
                          ),
                        )
                        .toList(),
                    onChanged: (w) {
                      if (w != null) setState(() => _selectedWeekIndex = w);
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: LineChart(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              LineChartData(
                minX: 0,
                maxX: (weekLength - 1).toDouble(),
                minY: 0,
                maxY: maxValue,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: textColor?.withValues(alpha: 0.1) ??
                        Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final dayNumber = startDay + value.toInt() + 1;
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: textColor?.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: toSpots(expenseSlice),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: expenseColor,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          expenseColor.withValues(alpha: 0.35),
                          expenseColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: toSpots(incomeSlice),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: incomeColor,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          incomeColor.withValues(alpha: 0.2),
                          incomeColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
