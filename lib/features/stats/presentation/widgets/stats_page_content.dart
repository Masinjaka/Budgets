import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/stats/domain/providers/stats_provider.dart';
import 'package:budgets/features/stats/presentation/widgets/budget_history_card.dart';
import 'package:budgets/features/stats/presentation/widgets/new_balance_card.dart';
import 'package:budgets/features/stats/presentation/widgets/new_category_breakdown.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_chart.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_skeleton.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StatsPageContent extends ConsumerWidget {
  final DateTime date;

  const StatsPageContent({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate start and end of the month
    final startDate = DateTime(date.year, date.month, 1);
    final endDate = DateTime(date.year, date.month + 1, 0);
    final daysInMonth = endDate.day;

    // Watch the period stats provider
    final periodStatsAsync = ref.watch(periodStatsProvider(startDate, endDate));

    // Watch categories for colors and emojis
    final categoriesAsync = ref.watch(categoriesProvider);

    // Watch transactions for chart data
    final transactionsAsync = ref.watch(transactionsProvider);

    return periodStatsAsync.when(
      data: (stats) {
        // Build category color and emoji maps
        final categoryColors = <String, String>{};
        final categoryEmojis = <String, String>{};

        categoriesAsync.whenData((categories) {
          for (final category in categories) {
            if (category.name != null) {
              categoryColors[category.name!] = category.color ?? '10B981';
              categoryEmojis[category.name!] = category.emoji ?? '💰';
            }
          }
        });

        // Build chart data from transactions
        final expenseData = List<double>.filled(daysInMonth, 0);
        final incomeData = List<double>.filled(daysInMonth, 0);

        transactionsAsync.whenData((transactions) {
          for (final transaction in transactions) {
            if (transaction.date == null) continue;
            final txDate = transaction.date!;

            // Check if transaction is in the selected month
            if (txDate.year == date.year && txDate.month == date.month) {
              final dayIndex = txDate.day - 1;
              if (dayIndex >= 0 && dayIndex < daysInMonth) {
                final amount = transaction.amount ?? 0.0;
                if (transaction.transactionType?.value == 'expense') {
                  expenseData[dayIndex] += amount;
                } else if (transaction.transactionType?.value == 'income') {
                  incomeData[dayIndex] += amount;
                }
              }
            }
          }
        });

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                child: StatsChart(
                  expenseData: expenseData,
                  incomeData: incomeData,
                  daysInMonth: daysInMonth,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Row(
                  children: [
                    Expanded(
                      child: NewBalanceCard(
                        type: BalanceCardType.expense,
                        amount: stats.totalExpenses,
                        iconData: Icons.arrow_upward,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: NewBalanceCard(
                        type: BalanceCardType.income,
                        amount: stats.totalIncome,
                        iconData: Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                child: NewCategoryBreakdown(
                  expensesByCategory: stats.expensesByCategory,
                  incomeByCategory: stats.incomeByCategory,
                  categoryColors: categoryColors,
                  categoryEmojis: categoryEmojis,
                ),
              ),
              // Budget History Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                child: BudgetHistoryCard(date: date),
              ),
              // Bottom padding for navigation bar
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
      loading: () => const SingleChildScrollView(child: StatsSkeleton()),
      error: (error, stack) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Center(
            child: Text(
              'Erreur lors du chargement des données',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
