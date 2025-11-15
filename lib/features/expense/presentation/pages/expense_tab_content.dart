import 'package:budgets/core/functions/transaction_utils.dart';
import 'package:budgets/core/functions/transaction_search_mixin.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/expense/presentation/widgets/transaction_state_widgets.dart';
import 'package:budgets/features/expense/presentation/widgets/transaction_search_section.dart';
import 'package:budgets/features/expense/presentation/widgets/transaction_date_group.dart';
import 'package:budgets/features/expense/presentation/widgets/transaction_empty_states.dart';
import 'package:budgets/provider/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Expense tab content that contains the search bar and expense list
class ExpenseTabContent extends ConsumerStatefulWidget {
  final AnimationController appBarAnimationController;
  
  const ExpenseTabContent({
    super.key,
    required this.appBarAnimationController,
  });

  @override
  ConsumerState<ExpenseTabContent> createState() => _ExpenseTabContentState();
}

class _ExpenseTabContentState extends ConsumerState<ExpenseTabContent> 
    with TransactionSearchMixin {

  @override
  Widget build(BuildContext context) {
    // Watch expense data from provider
    final asyncExpenses = ref.watch(expensesProvider);
    
    return asyncExpenses.when(
      data: (allExpenses) {
        // Filter to only show expenses (transaction_type = 'expense')
        final expenses = TransactionUtils.filterByTransactionType(
          allExpenses, 
          TransactionType.expense,
        );
        
        // Filter and group expenses
        final filteredExpenses = TransactionUtils.filterTransactions(
          expenses,
          searchController.text,
          selectedCategories,
        );
        final groupedTransactions = TransactionUtils.groupTransactionsByDate(
          filteredExpenses,
          localeInitialized,
        );
        final availableCategories = TransactionUtils.extractCategoriesFromTransactions(expenses);

        return CustomScrollView(
          slivers: [
            // Search bar section
            SliverToBoxAdapter(
              child: TransactionSearchSection(
                isSearchFocused: isSearchFocused,
                onSearchFocused: () => onSearchFocused(widget.appBarAnimationController),
                onSearchUnfocused: () => onSearchUnfocused(widget.appBarAnimationController),
                onClearSearch: onClearSearch,
                searchController: searchController,
                hintText: 'Rechercher...',
                availableCategories: availableCategories,
                selectedCategories: selectedCategories,
                onCategorySelectionChanged: onCategorySelectionChanged,
              ),
            ),
            // Expense list content
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              sliver: groupedTransactions.isEmpty
                  ? SliverToBoxAdapter(child: ExpenseEmptyState(hasFilters: hasFilters))
                  : TransactionDateGroup(groupedTransactions: groupedTransactions),
            ),
          ],
        );
      },
      loading: () => const TransactionLoadingState(),
      error: (error, stack) => TransactionErrorState(
        error: error,
        errorMessage: 'Erreur lors du chargement des dépenses',
      ),
    );
  }
}
