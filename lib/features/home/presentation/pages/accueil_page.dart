import 'package:budgets/core/theme.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:budgets/provider/expense_provider.dart';
import 'package:budgets/provider/filter_provider.dart';
import 'package:budgets/widgets/custom_expense_card.dart';
import 'package:budgets/features/home/presentation/widgets/custom_greeting_app_bar.dart';
import 'package:budgets/features/home/presentation/widgets/jumbotron.dart';
import 'package:budgets/features/home/presentation/widgets/section_title.dart';
import 'package:budgets/features/home/presentation/widgets/stats_home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<String?> _selectedCategories = [];
  DateTimeRange? dateRange;

  @override
  Widget build(BuildContext context) {
    final asyncExpenses = ref.watch(expensesProvider);

    _selectedCategories = ref.watch(selectedCategoriesProvider);

    dateRange = ref.watch(dateRangeProvider);

    return SafeArea(
      child: Scaffold(
        appBar: const CustomGreetingAppBar(),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 3.h),
                  const Jumbotron(),
                  SizedBox(height: 3.h),
                  SectionTitle(
                    title: 'Vue d\'ensemble',
                    onTap: () {},
                  ),
                  SizedBox(height: 3.h),
                  StatsHomeWidget(asyncExpenses: asyncExpenses),
                  SizedBox(height: 3.h),
                  SectionTitle(
                    title: 'Activités récentes',
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
      ),
    );
  }

  _buildExpenseList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text('Vous n\' avez pas encore de depense'),
      );
    }

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

    expenses.sort((a, b) => b.date!.compareTo(a.date!));

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
}
