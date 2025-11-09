import 'package:budgets/core/theme.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:budgets/provider/expense_provider.dart';
import 'package:budgets/provider/filter_provider.dart';
import 'package:budgets/utils/chart_data.dart';
import 'package:budgets/widgets/charts/bar_chart.dart';
import 'package:budgets/widgets/charts/line_chart.dart';
import 'package:budgets/widgets/custom_expense_card.dart';
import 'package:budgets/widgets/expense_widgets/custom_greeting_app_bar.dart';
import 'package:budgets/widgets/expense_widgets/jumbotron.dart';
import 'package:budgets/widgets/expense_widgets/section_title.dart';
import 'package:budgets/widgets/expense_widgets/stats_home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpensePage extends ConsumerStatefulWidget {
  const ExpensePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpensePageState();
}

class _ExpensePageState extends ConsumerState<ExpensePage> {
  List<String?> _selectedCategories = [];
  DateTimeRange? dateRange;
  final List<bool> _isSelected = [true, false, false];

  @override
  Widget build(BuildContext context) {
    final asyncExpenses = ref.watch(expensesProvider);

    _selectedCategories = ref.watch(selectedCategoriesProvider);

    dateRange = ref.watch(dateRangeProvider);

    return Scaffold(
      appBar: const CustomGreetingAppBar(
        greeting: 'Bonjour Masinjaka!',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 2.h),
                const Jumbotron(),
                SizedBox(height: 3.h),
                SectionTitle(
                  title: 'VUE D\'ENSEMBLE',
                  onTap: () {},
                ),
                SizedBox(height: 3.h),
                StatsHomeWidget(asyncExpenses: asyncExpenses),
                SizedBox(height: 3.h),
                SectionTitle(
                  title: 'ACTIVITÉS RÉCENTES',
                  onTap: () {
                    context.push('/expense-list');
                  },
                ),
                SizedBox(height: 2.h),
                switch (asyncExpenses) {
                  AsyncData(:final value) => _buildExpenseList(value),
                  AsyncError(:final error) => Text('error: $error'),
                  _ => const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the current budget section with a row of budget cards.
  Row _buildCurrentBudget(AsyncValue<List<Expense>> asyncExpenses) {
    return Row(
      children: [
        Expanded(
          child: switch (asyncExpenses) {
            AsyncData(:final value) => _buildCurrentBudgets(
                value,
                false,
                title: 'Dépenses',
              ),
            AsyncError(:final error) => Text('error: $error'),
            _ => _buildCurrentBudgets(
                [],
                true,
                title: 'Dépenses',
              ),
          },
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildCurrentBudgets(
            [],
            false,
            title: 'Revenus',
          ),
        )
      ],
    );
  }

  // Builds the recent expenses section with a list of expense tiles.
  Container _buildRecentExpense(AsyncValue<List<Expense>> asyncExpenses) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
      height: 40.h,
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(
          color: AppTheme.borderColorDark,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ACTIVITÉS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  )),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Voir plus',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          const Divider(
            color: Color.fromARGB(255, 48, 48, 48),
            thickness: 1,
          ),
          SizedBox(height: 0.5.h),
          switch (asyncExpenses) {
            AsyncData(:final value) => _buildExpenseList(value),
            AsyncError(:final error) => Text('error: $error'),
            _ => const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                ),
              ),
          },
        ],
      ),
    );
  }

  // Builds the statistics section with a toggle for daily, weekly, and monthly views.
  Container _buildStats(
    AsyncValue<List<Expense>> asyncExpenses,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
      height: 40.h,
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(
          color: AppTheme.borderColorDark,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('VUE D\'ENSEMBLE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  )),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Voir plus',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          const Divider(
            color: Color.fromARGB(255, 48, 48, 48),
            thickness: 1,
          ),
          SizedBox(height: 1.h),
          ToggleButtons(
            isSelected: _isSelected,
            onPressed: (int index) {
              setState(() {
                // Update the selected state of the toggle buttons.
                for (int buttonIndex = 0;
                    buttonIndex < _isSelected.length;
                    buttonIndex++) {
                  _isSelected[buttonIndex] = buttonIndex == index;
                }
              });
            },
            constraints: BoxConstraints(
              minHeight: 3.h,
            ),
            borderRadius: BorderRadius.circular(10.w),
            fillColor: Colors.white,
            color: Colors.white,
            selectedColor: Colors.black,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: const Text(
                  'Hebdomadaire',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: const Text(
                  'Mensuel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: const Text(
                  'Annuelle',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          switch (asyncExpenses) {
            AsyncData(:final value) => _isSelected[0]
                ? dailyBarChart(value)
                : _isSelected[1]
                    ? buildLineChart(
                        AppChartData.getMonthlyData(value), 'Weekly', value)
                    : buildLineChart(
                        AppChartData.getYearlyData(value), 'Monthly', value),
            AsyncError(:final error) => Text('error: $error'),
            _ => const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                ),
              ),
          },
        ],
      ),
    );
  }

  // Builds the current budgets section with a list of budget cards.
  Container _buildCurrentBudgets(List<dynamic> budgets, bool isSkeleton,
      {required String title}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
      height: 15.h,
      decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(
            color: AppTheme.borderColorDark,
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Text(
              title,
              style: GoogleFonts.alexandria(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Flexible(
            child: isSkeleton
                ? Container(
                    color: Colors.grey,
                    height: 1.5.w,
                    width: 2.h,
                  )
                : _buildTotal(budgets),
          ),
          Flexible(
              child: Text(
            'MGA',
            style: GoogleFonts.alexandria(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          )),
        ],
      ),
    );
  }

  // Builds the list of recent expenses with expense tiles.
  _buildExpenseList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text('Vous n\' avez pas encore de depense'),
      );
    }

    // Filter the list
    if (_selectedCategories.isNotEmpty) {
      expenses = expenses
          .where(
              (expense) => _selectedCategories.contains(expense.category?.name))
          .toList();
    }

    if (dateRange != null) {
      expenses = expenses.where((expense) {
        final expenseDate = expense.date!;
        return expenseDate.isAfter(dateRange!.start) &&
            expenseDate.isBefore(dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort the expense list
    expenses.sort((a, b) => b.date!.compareTo(a.date!));

    // Keep only the first 4 expenses
    expenses = expenses.take(4).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: expenses
          .map(
            (e) => ExpenseTile(
              designation: e.title ?? "Designation inconnue",
              category: e.category?.name ?? "Categorie inconnue",
              amount: e.amount?.toString() ?? "Montant inconnue",
              date: e.date!,
              categoryColor: Color(int.parse(e.category!.color!, radix: 16)),
              categoryEmoji: e.category?.emoji ?? '❓',
              description: e.description ?? "Aucune description",
              categoryId: e.category?.id ?? "",
            ),
          )
          .toList(),
    );
  }

  // Builds the total amount for the current month.
  Text _buildTotal(List<dynamic> value) {
    if (value.isEmpty) {
      return Text(
        '0',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }
    final now = DateTime.now();
    final currentMonthExpenses = value.where((expense) =>
        expense.date!.year == now.year && expense.date!.month == now.month);

    final totalAmount = currentMonthExpenses.fold<double>(
        0, (sum, expense) => sum + (expense.amount ?? 0));

    final formattedTotalAmount =
        totalAmount.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (match) => '${match[1]} ',
            );

    return Text(
      formattedTotalAmount,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
