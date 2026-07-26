import 'package:budgets/features/stats/presentation/widgets/stats_skeleton_balance_card.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_skeleton_category_breakdown.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_skeleton_chart.dart';
import 'package:flutter/material.dart';

class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              const Expanded(child: StatsSkeletonBalanceCard()),
              SizedBox(width: 16),
              const Expanded(child: StatsSkeletonBalanceCard()),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: const StatsSkeletonChart(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: const StatsSkeletonCategoryBreakdown(),
        ),
      ],
    );
  }
}
