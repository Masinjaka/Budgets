import 'package:budgets/core/theme.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:budgets/utils/chart_data.dart';
import 'package:budgets/widgets/charts/line_chart.dart';
import 'package:budgets/widgets/time_period_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StatsHomeWidget extends StatelessWidget {
  const StatsHomeWidget({
    super.key,
    required this.asyncExpenses,
  });

  final AsyncValue<List<Expense>> asyncExpenses;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      padding: EdgeInsets.only(bottom: 2.h, left: 5.w, right: 5.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(
          color: AppTheme.borderColorDark,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top:4.w,bottom: 4.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TimePeriodDropdown(
                defaultText: 'Hébdomadaire',
                onChanged: (String? period) {
                  // Handle period change
                  print('Selected period: $period');
                },
              ),
            ),
          ),
          switch (asyncExpenses) {
            AsyncData(:final value) => buildLineChart(
                AppChartData.getMonthlyData(value),
                'Weekly',
                value),
            AsyncError(:final error) => Text('error: $error'),
            _ => const Center(
                child: CircularProgressIndicator(
                  color: Colors.grey,
                ),
              ),
          },
        ],
      ),
    );
  }
}
