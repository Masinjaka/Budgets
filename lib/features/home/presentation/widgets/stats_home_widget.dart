import 'package:budgets/core/theme.dart';
import 'package:budgets/features/transactions/domain/model/expense_model.dart';
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
          // Legend for the chart
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Dépenses', Colors.redAccent),
              SizedBox(width: 4.w),
              _buildLegendItem('Revenus', Colors.greenAccent),
            ],
          ),
          SizedBox(height: 2.h),
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.w),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
