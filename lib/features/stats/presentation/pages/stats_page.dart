import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/stats/domain/providers/selected_date_provider.dart';
import 'package:budgets/features/stats/domain/providers/stats_provider.dart';
import 'package:budgets/features/stats/presentation/widgets/month_year_picker.dart';
import 'package:budgets/features/stats/presentation/widgets/new_balance_card.dart';
import 'package:budgets/features/stats/presentation/widgets/new_category_breakdown.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_chart.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final selectedDate = ref.watch(selectedDateProvider);

    // Calculate start and end of the selected month
    final startDate = DateTime(selectedDate.year, selectedDate.month, 1);
    final endDate = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final daysInMonth = endDate.day;

    // Watch the period stats provider
    final periodStatsAsync = ref.watch(periodStatsProvider(startDate, endDate));

    // Watch categories for colors and emojis
    final categoriesAsync = ref.watch(categoriesProvider);

    // Watch transactions for chart data
    final transactionsAsync = ref.watch(transactionsProvider);

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
                periodStatsAsync.when(
                  data: (stats) {
                    // Build category color and emoji maps
                    final categoryColors = <String, String>{};
                    final categoryEmojis = <String, String>{};

                    categoriesAsync.whenData((categories) {
                      for (final category in categories) {
                        if (category.name != null) {
                          categoryColors[category.name!] =
                              category.color ?? '10B981';
                          categoryEmojis[category.name!] =
                              category.emoji ?? '💰';
                        }
                      }
                    });

                    // Build chart data from transactions
                    final expenseData = List<double>.filled(daysInMonth, 0);
                    final incomeData = List<double>.filled(daysInMonth, 0);

                    transactionsAsync.whenData((transactions) {
                      for (final transaction in transactions) {
                        if (transaction.date == null) continue;
                        final date = transaction.date!;

                        // Check if transaction is in the selected month
                        if (date.year == selectedDate.year &&
                            date.month == selectedDate.month) {
                          final dayIndex = date.day - 1;
                          if (dayIndex >= 0 && dayIndex < daysInMonth) {
                            final amount = transaction.amount ?? 0.0;
                            if (transaction.transactionType?.value ==
                                'expense') {
                              expenseData[dayIndex] += amount;
                            } else if (transaction.transactionType?.value ==
                                'income') {
                              incomeData[dayIndex] += amount;
                            }
                          }
                        }
                      }
                    });

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: NewBalanceCard(
                                  type: BalanceCardType.expense,
                                  amount: stats.totalExpenses,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: NewBalanceCard(
                                  type: BalanceCardType.income,
                                  amount: stats.totalIncome,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: StatsChart(
                            expenseData: expenseData,
                            incomeData: incomeData,
                            daysInMonth: daysInMonth,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: NewCategoryBreakdown(
                            expensesByCategory: stats.expensesByCategory,
                            incomeByCategory: stats.incomeByCategory,
                            categoryColors: categoryColors,
                            categoryEmojis: categoryEmojis,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(16.0),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
