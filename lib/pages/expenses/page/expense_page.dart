import 'package:budgets/core/theme.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:budgets/provider/app_theme_provider.dart';
import 'package:budgets/provider/expense_provider.dart';
import 'package:budgets/provider/filter_provider.dart';
import 'package:budgets/widgets/custom_app_bar.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_expense_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final asyncExpenses = ref.watch(expensesProvider);

    _selectedCategories = ref.watch(selectedCategoriesProvider);

    dateRange = ref.watch(dateRangeProvider);

    final globalTheme = ref.watch(globalThemeProvider);

    bool isDarkMode = globalTheme == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        toolbarHeight: 8.h,
        elevation: 0,
        title: const CustomAppBar(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: _buildExpenseTotal(
                  asyncExpenses,
                  globalTheme,
                ),
              ),
              SizedBox(height: 1.h),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dépenses récentes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5.sp,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.h),
                        border: Border.all(
                            color:
                                isDarkMode ? AppTheme.textDark : Colors.black),
                      ),
                      child: InkWell(
                        onTap: () => context.push('/filter-expense'),
                        splashColor: Colors.transparent,
                        child: Icon(
                          Icons.filter_alt_outlined,
                          color: isDarkMode ? AppTheme.textDark : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              Expanded(
                flex: 7,
                child: SizedBox(
                  height: double.infinity,
                  child: switch (asyncExpenses) {
                    AsyncData(:final value) => _buildExpenseList(value),
                    AsyncError(:final error) => Text('error: $error'),
                    _ => const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryLight,
                        ),
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildAddButton(),
    );
  }

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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: expenses
            .map(
              (e) => ExpenseTile(
                designation: e.title ?? "Designation inconnue",
                category: e.category?.name ?? "Categorie inconnue",
                amount: e.amount?.toString() ?? "Montant inconnue",
                date: e.date!,
              ),
            )
            .toList(),
      ),
    );
  }

  Container _buildExpenseTotal(AsyncValue<List<Expense>> asyncExpenses, Brightness globalTheme) {
    bool isDarkMode = globalTheme == Brightness.dark;

    Color textColor = isDarkMode ? AppTheme.textDark : Colors.black;
    Color backgroundColor =
        isDarkMode ? AppTheme.secondaryDark : AppTheme.secondaryLight;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Mes depenses ce mois-ci',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.5.sp,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: switch (asyncExpenses) {
              AsyncData(:final value) => _buildTotal(value),
              AsyncError(:final error) => Text('error: $error'),
              _ => const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryLight,
                  ),
                ),
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.h),
                border: Border.all(color: textColor),
              ),
              child: Icon(
                Icons.insights,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text _buildTotal(List<Expense> value) {
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
      'Ar $formattedTotalAmount',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22.sp,
      ),
    );
  }

  Padding _buildAddButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: CustomButton(
        text: 'Ajouter un achat',
        onPressed: () async {
          if (!mounted) return;
          context.push('/add-expense');
        },
      ),
    );
  }
}

class Pills extends ConsumerStatefulWidget {
  const Pills({
    super.key,
    required this.text,
  });

  final String text;

  @override
  ConsumerState<Pills> createState() => _PillsState();
}

class _PillsState extends ConsumerState<Pills> {
  @override
  Widget build(BuildContext context) {

    final globalTheme = ref.watch(globalThemeProvider);

    bool isDarkMode = globalTheme == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.backgroundDark : Colors.transparent,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(
            color: isDarkMode ? AppTheme.backgroundDark : Colors.black),
      ),
      child: Text(
        widget.text,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: isDarkMode ? AppTheme.textDark : Colors.black,
        ),
      ),
    );
  }
}
