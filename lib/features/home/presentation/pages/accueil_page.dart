import 'package:budgets/core/theme.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/features/categories/domain/providers/filter_provider.dart';
import 'package:budgets/widgets/custom_transaction_card.dart';
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
    final asyncTransactions = ref.watch(transactionsProvider);

    _selectedCategories = ref.watch(selectedCategoriesProvider);

    dateRange = ref.watch(dateRangeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomGreetingAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                    height: 14.h), // Adjusted for AppBar height + Safe Area
                const Jumbotron(),
                SizedBox(height: 3.h),
                SectionTitle(
                  title: 'Activités récentes',
                  onTap: () {
                    context.go('/transaction-list');
                  },
                ),
                SizedBox(height: 2.h),
                switch (asyncTransactions) {
                  AsyncData(:final value) => _buildTransactionList(value),
                  AsyncError(:final error) => Text('error: $error'),
                  _ => const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                },
                SizedBox(height: 3.h),
                SectionTitle(
                  title: 'Vue d\'ensemble',
                  onTap: () {
                    context.go('/stats');
                  },
                ),
                SizedBox(height: 3.h),
                StatsHomeWidget(asyncExpenses: asyncTransactions),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildTransactionList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('Vous n\' avez pas encore de depense'),
      );
    }

    if (_selectedCategories.isNotEmpty) {
      transactions = transactions
          .where((transaction) =>
              _selectedCategories.contains(transaction.category?.name))
          .toList();
    }

    if (dateRange != null) {
      transactions = transactions.where((transaction) {
        final transactionDate = transaction.date!;
        return transactionDate.isAfter(dateRange!.start) &&
            transactionDate
                .isBefore(dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    transactions.sort((a, b) => b.date!.compareTo(a.date!));

    transactions = transactions.take(4).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: transactions
          .map(
            (e) => TransactionTile(
              designation: e.title ?? "Designation inconnue",
              category: e.category?.name ?? "Categorie inconnue",
              amount: e.amount?.toString() ?? "Montant inconnue",
              date: e.date!,
              categoryColor: Color(int.parse(e.category!.color!, radix: 16)),
              categoryEmoji: e.category?.emoji ?? '❓',
              description: e.description ?? "Aucune description",
              categoryId: e.category?.id ?? "",
              transactionType: e.transactionType?.value ?? "expense",
            ),
          )
          .toList(),
    );
  }
}
