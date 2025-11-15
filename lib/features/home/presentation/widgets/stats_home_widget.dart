import 'package:budgets/core/theme.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:budgets/widgets/charts/bar_chart.dart';
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
      ),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          switch (asyncExpenses) {
            AsyncData(:final value) => dailyBarChart(value),
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
