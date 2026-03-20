import 'package:budgets/features/stats/presentation/widgets/stats_skeleton_balance_card.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_skeleton_category_breakdown.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_skeleton_chart.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              const Expanded(child: StatsSkeletonBalanceCard()),
              SizedBox(width: 4.w),
              const Expanded(child: StatsSkeletonBalanceCard()),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          child: const StatsSkeletonChart(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          child: const StatsSkeletonCategoryBreakdown(),
        ),
      ],
    );
  }
}
