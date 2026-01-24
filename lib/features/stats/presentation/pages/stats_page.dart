import 'package:budgets/features/stats/presentation/widgets/month_year_picker.dart';
import 'package:budgets/features/stats/presentation/widgets/new_balance_card.dart';
import 'package:budgets/features/stats/presentation/widgets/new_category_breakdown.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              'Rapports',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            centerTitle: true,
            pinned: true,
            floating: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: MonthYearPicker(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(child: NewBalanceCard()),
                      SizedBox(width: 16.0),
                      Expanded(child: NewBalanceCard()),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: StatsChart(),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: NewCategoryBreakdown(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
