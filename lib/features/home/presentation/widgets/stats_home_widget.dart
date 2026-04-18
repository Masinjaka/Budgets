import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/widgets/charts/bar_chart.dart';
import 'package:budgets/widgets/skeleton/home_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StatsHomeWidget extends ConsumerWidget {
  const StatsHomeWidget({
    super.key,
    required this.asyncExpenses,
  });

  final AsyncValue<List<TransactionModel>> asyncExpenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyControllerProvider);

    return Container(
      height: 35.h,
      padding: EdgeInsets.only(bottom: 2.h, left: 5.w, right: 5.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          // Legend for the chart
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, 'Dépenses', Colors.redAccent),
              SizedBox(width: 4.w),
              _buildLegendItem(context, 'Revenus', Colors.greenAccent),
            ],
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: switch (asyncExpenses) {
              AsyncData(:final value) => currencyState.when(
                  data: (currency) => dailyBarChart(
                    value,
                    currencyRate: currency.rateFor(currency.code),
                  ),
                  loading: () => const StatsHomeWidgetSkeleton(),
                  error: (error, _) => Text('error: $error'),
                ),
              AsyncError(:final error) => Text('error: $error'),
              _ => const StatsHomeWidgetSkeleton(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
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
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
