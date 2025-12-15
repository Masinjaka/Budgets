import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/functions/chart_data.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/widgets/charts/bar_chart.dart';
import 'package:budgets/widgets/charts/bar_chart_stats.dart';
import 'package:budgets/widgets/charts/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncTransactions = ref.watch(transactionsProvider);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceDim = Theme.of(context).colorScheme.surface;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 2.h),
            // Modern Pill Tab Bar
            Center(
              child: Container(
                width: 90.w,
                decoration: BoxDecoration(
                  color: surfaceDim,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.all(1.w),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: textColor,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                  ),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      return states.contains(WidgetState.focused)
                          ? null
                          : Colors.transparent;
                    },
                  ),
                  tabs: const [
                    Tab(text: 'Jour'),
                    Tab(text: 'Semaine'),
                    Tab(text: 'Mois'),
                    Tab(text: 'Année'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Expanded(
              child: asyncTransactions.when(
                data: (transactions) => TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDailyView(transactions, surfaceDim, textColor),
                    _buildWeeklyView(transactions, surfaceDim, textColor),
                    _buildMonthlyView(transactions, surfaceDim, textColor),
                    _buildYearlyView(transactions, surfaceDim, textColor),
                  ],
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text('Erreur: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter transactions for daily view (current day only)
  List<TransactionModel> _filterDailyTransactions(
      List<TransactionModel> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return transactions.where((transaction) {
      final transactionDay = DateTime(transaction.date!.year,
          transaction.date!.month, transaction.date!.day);
      return transactionDay.isAtSameMomentAs(today);
    }).toList();
  }

  // Filter transactions for weekly view (last 7 days)
  List<TransactionModel> _filterWeeklyTransactions(
      List<TransactionModel> transactions) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final weekAgoDay = DateTime(weekAgo.year, weekAgo.month, weekAgo.day);

    return transactions.where((transaction) {
      final transactionDay = DateTime(transaction.date!.year,
          transaction.date!.month, transaction.date!.day);
      return transactionDay
          .isAfter(weekAgoDay.subtract(const Duration(days: 1)));
    }).toList();
  }

  // Filter transactions for monthly view (last 4 weeks)
  List<TransactionModel> _filterMonthlyTransactions(
      List<TransactionModel> transactions) {
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 27));
    final fourWeeksAgoDay =
        DateTime(fourWeeksAgo.year, fourWeeksAgo.month, fourWeeksAgo.day);

    return transactions.where((transaction) {
      final transactionDay = DateTime(transaction.date!.year,
          transaction.date!.month, transaction.date!.day);
      return transactionDay
          .isAfter(fourWeeksAgoDay.subtract(const Duration(days: 1)));
    }).toList();
  }

  // Filter transactions for yearly view (last 12 months)
  List<TransactionModel> _filterYearlyTransactions(
      List<TransactionModel> transactions) {
    final now = DateTime.now();
    final twelveMonthsAgo = DateTime(now.year, now.month - 11, 1);

    return transactions.where((transaction) {
      final transactionMonth =
          DateTime(transaction.date!.year, transaction.date!.month, 1);
      return transactionMonth
              .isAfter(twelveMonthsAgo.subtract(const Duration(days: 1))) ||
          transactionMonth.isAtSameMomentAs(twelveMonthsAgo);
    }).toList();
  }

  Widget _buildDailyView(
      List<TransactionModel> transactions, Color surfaceDim, Color? textColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Transactions par heure', textColor),
            SizedBox(height: 2.h),
            Card(
              color: surfaceDim,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.w),
              ),
              child: Container(
                height: 35.h,
                padding: EdgeInsets.all(4.w),
                child: dailyHourlyBarChart(transactions),
              ),
            ),
            SizedBox(height: 3.h),
            _buildSectionTitle('Dépenses par catégorie', textColor),
            SizedBox(height: 2.h),
            _buildCategoryPieSection(_filterDailyTransactions(transactions),
                TransactionType.expense, surfaceDim),
            SizedBox(height: 3.h),
            _buildSectionTitle('Revenus par catégorie', textColor),
            SizedBox(height: 2.h),
            _buildCategoryPieSection(_filterDailyTransactions(transactions),
                TransactionType.income, surfaceDim),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyView(
      List<TransactionModel> transactions, Color surfaceDim, Color? textColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Transactions par jour', textColor),
            SizedBox(height: 2.h),
            Card(
              color: surfaceDim,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.w),
              ),
              child: Container(
                height: 35.h,
                padding: EdgeInsets.all(4.w),
                child: dailyBarChart(transactions),
              ),
            ),
            SizedBox(height: 3.h),
            _buildSectionTitle('Dépenses par catégorie', textColor),
            SizedBox(height: 2.h),
            _buildCategoryPieSection(_filterWeeklyTransactions(transactions),
                TransactionType.expense, surfaceDim),
            SizedBox(height: 3.h),
            _buildSectionTitle('Revenus par catégorie', textColor),
            SizedBox(height: 2.h),
            _buildCategoryPieSection(_filterWeeklyTransactions(transactions),
                TransactionType.income, surfaceDim),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyView(
      List<TransactionModel> transactions, Color surfaceDim, Color? textColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Transactions par semaine', textColor),
            SizedBox(height: 2.h),
            Card(
              color: surfaceDim,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.w),
              ),
              child: Container(
                height: 35.h,
                padding: EdgeInsets.all(4.w),
                child: monthlyWeeklyBarChart(transactions),
              ),
            ),
            SizedBox(height: 3.h),
            _buildSectionTitle('Dépenses par catégorie', textColor),
            SizedBox(height: 2.h),
            _buildCategoryPieSection(_filterMonthlyTransactions(transactions),
                TransactionType.expense, surfaceDim),
            SizedBox(height: 3.h),
            _buildSectionTitle('Revenus par catégorie', textColor),
            SizedBox(height: 2.h),
            _buildCategoryPieSection(_filterMonthlyTransactions(transactions),
                TransactionType.income, surfaceDim),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyView(
      List<TransactionModel> transactions, Color surfaceDim, Color? textColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Transactions par mois', textColor),
            SizedBox(height: 2.h),
            Card(
              color: surfaceDim,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.w),
              ),
              child: Container(
                height: 35.h,
                padding: EdgeInsets.all(4.w),
                child: yearlyMonthlyBarChart(transactions),
              ),
            ),
            SizedBox(height: 3.h),
            _buildSectionTitle('Dépenses par catégorie', textColor),
            SizedBox(height: 2.h),
            _buildCategoryPieSection(_filterYearlyTransactions(transactions),
                TransactionType.expense, surfaceDim),
            SizedBox(height: 3.h),
            _buildSectionTitle('Revenus par catégorie', textColor),
            SizedBox(height: 2.h),
            _buildCategoryPieSection(_filterYearlyTransactions(transactions),
                TransactionType.income, surfaceDim),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color? textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildCategoryPieSection(List<TransactionModel> transactions,
      TransactionType type, Color surfaceDim) {
    final categoryData = AppChartData.getCategoryPieData(transactions, type);
    final categoryTotals = categoryData['totals'] as Map<String, double>;
    final categoryColors = categoryData['colors'] as Map<String, String>;
    final categoryEmojis = categoryData['emojis'] as Map<String, String>;

    return Card(
      color: surfaceDim,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: categoryPieChart(
            categoryTotals, categoryColors, categoryEmojis, type, surfaceDim),
      ),
    );
  }
}
