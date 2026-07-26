import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Builds and returns a [PieChart] widget for category breakdown
Widget categoryPieChart(
    Map<String, double> categoryTotals,
    Map<String, String> categoryColors,
    Map<String, String> categoryEmojis,
    TransactionType type,
    Color backgroundColor,
    {required double currencyRate,
    required String currencyCode}) {
  if (categoryTotals.isEmpty) {
    return Center(
      child: Text(
        type == TransactionType.expense ? 'Aucune dépense' : 'Aucun revenu',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  final total = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
  List<PieChartSectionData> sections = [];

  categoryTotals.forEach((category, amount) {
    final color =
        Color(int.parse(categoryColors[category] ?? 'FF10B981', radix: 16));

    sections.add(
      PieChartSectionData(
        value: amount,
        title: '', // No title/percentage on the pie chart
        color: color,
        radius: 100,
        titleStyle: const TextStyle(fontSize: 0), // Hidden
        borderSide: BorderSide(color: backgroundColor, width: 1),
      ),
    );
  });

  return Column(
    children: [
      SizedBox(
        height: 240,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.001, end: 1),
          duration: const Duration(seconds: 1),
          curve: Curves.fastLinearToSlowEaseIn,
          builder: (context, value, child) {
            final List<PieChartSectionData> animatedSections =
                List.from(sections);

            // Calculate dummy value
            // When value is 1, dummyValue is 0.
            final dummyValue = total * (1 - value) / value;

            // Always add dummy section to keep list stable
            animatedSections.add(
              PieChartSectionData(
                value: dummyValue,
                color: Colors.transparent,
                radius: 100,
                showTitle: false,
              ),
            );

            return PieChart(
              PieChartData(
                startDegreeOffset: 270, // Start from top
                sections: animatedSections,
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            );
          },
        ),
      ),
      SizedBox(height: 24),
      // Progress bars (gauges) for each category
      ...categoryTotals.entries.map((entry) {
        final color = Color(
            int.parse(categoryColors[entry.key] ?? 'FF10B981', radix: 16));
        final emoji = categoryEmojis[entry.key] ?? '❓';
        final percentage = (entry.value / total) * 100;

        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category name, emoji, and amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(emoji, style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${formatAmountWithCurrency(entry.value * currencyRate, currencyCode)} '
                    '(${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 12,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }),
    ],
  );
}
