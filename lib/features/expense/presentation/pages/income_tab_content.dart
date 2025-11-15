import 'package:budgets/core/theme.dart';
import 'package:budgets/core/transaction_type.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:budgets/provider/expense_provider.dart';
import 'package:budgets/widgets/expense_widgets/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

/// Income tab content with all income-related features
class IncomeTabContent extends ConsumerStatefulWidget {
  final AnimationController? appBarAnimationController;
  
  const IncomeTabContent({
    super.key,
    this.appBarAnimationController,
  });

  @override
  ConsumerState<IncomeTabContent> createState() => _IncomeTabContentState();
}

class _IncomeTabContentState extends ConsumerState<IncomeTabContent> {
  // Search state management for income
  bool isSearchFocused = false;
  final TextEditingController searchController = TextEditingController();

  // TODO: Add income-specific state variables
  // List<Category> selectedIncomeCategories = [];
  // bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    // TODO: Initialize income-specific functionality
    // _initializeLocale();
    // searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  // TODO: Implement income-specific methods
  /*
  void _onSearchChanged() {
    setState(() {});
  }

  void _onSearchFocused() {
    setState(() {
      isSearchFocused = true;
    });
    widget.appBarAnimationController?.animateTo(0.0);
  }

  void _onSearchUnfocused() {
    setState(() {
      isSearchFocused = false;
    });
    widget.appBarAnimationController?.animateTo(1.0);
    FocusScope.of(context).unfocus();
  }

  void _onClearSearch() {
    searchController.clear();
  }
  */

  @override
  Widget build(BuildContext context) {
    // Watch expense data from provider
    final asyncExpenses = ref.watch(expensesProvider);
    
    return asyncExpenses.when(
      data: (allTransactions) {
        // Filter to only show incomes (transaction_type = 'income')
        final incomes = allTransactions.where((transaction) => 
          transaction.transactionType == TransactionType.income
        ).toList();
        
        if (incomes.isEmpty) {
          return _buildEmptyState();
        }

        // Group incomes by date
        final groupedIncomes = _groupTransactionsByDate(incomes);

        return CustomScrollView(
          slivers: [
            // Search bar section (for future implementation)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 1.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryDark.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3.w),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.white54,
                              size: 20.sp,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Recherche des revenus (bientôt disponible)',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Income list content
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final date = groupedIncomes.keys.elementAt(index);
                    final transactions = groupedIncomes[date]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 2.w, 0, 2.w),
                          child: Text(
                            date,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5.sp,
                            ),
                          ),
                        ),
                        // ListView for transactions under a specific date
                        ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: transactions.length,
                          itemBuilder: (context, i) {
                            return TransactionListItem(transaction: transactions[i]);
                          },
                          separatorBuilder: (context, i) => SizedBox(height: 1.h),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    );
                  },
                  childCount: groupedIncomes.length,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  /// Groups transactions by date and formats the date strings
  Map<String, List<Expense>> _groupTransactionsByDate(List<Expense> transactions) {
    final Map<String, List<Expense>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final transaction in transactions) {
      if (transaction.date == null) continue;

      final transactionDate = DateTime(
        transaction.date!.year,
        transaction.date!.month,
        transaction.date!.day,
      );

      String dateKey;
      if (transactionDate.isAtSameMomentAs(today)) {
        dateKey = "Aujourd'hui";
      } else if (transactionDate.isAtSameMomentAs(yesterday)) {
        dateKey = "Hier";
      } else {
        dateKey = DateFormat('dd MMMM yyyy', 'fr').format(transaction.date!);
      }

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }

    // Sort each group by time (most recent first)
    grouped.forEach((key, value) {
      value.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    });

    return grouped;
  }

  /// Build loading state widget
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryGreen,
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'Erreur lors du chargement des revenus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            error.toString(),
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(expensesProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: AppTheme.secondaryDark,
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  /// Build empty state widget for incomes
  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animation
                Icon(
                  Icons.trending_up,
                  size: 80,
                  color: AppTheme.primaryGreen,
                ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ).fadeIn(
                  duration: 400.ms,
                ),
                
                SizedBox(height: 3.h),
                
                // Title
                Text(
                  'Aucun revenu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 500.ms,
                  delay: 200.ms,
                  curve: Curves.easeOutCubic,
                ).fadeIn(
                  duration: 400.ms,
                  delay: 200.ms,
                ),
                
                SizedBox(height: 2.h),
                
                // Description
                Text(
                  'Vous n\'avez encore enregistré aucun revenu.\nCommencez par ajouter vos premiers revenus.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.sp,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ).animate().slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 500.ms,
                  delay: 400.ms,
                  curve: Curves.easeOutCubic,
                ).fadeIn(
                  duration: 400.ms,
                  delay: 400.ms,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
