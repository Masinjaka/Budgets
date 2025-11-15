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

class _IncomeTabContentState extends ConsumerState<IncomeTabContent> 
    with TransactionSearchMixin {

  @override
  Widget build(BuildContext context) {
    // Watch expense data from provider
    final asyncExpenses = ref.watch(expensesProvider);
    
    return asyncExpenses.when(
      data: (allTransactions) {
        // Filter to only show incomes (transaction_type = 'income')
        final incomes = TransactionUtils.filterByTransactionType(
          allTransactions, 
          TransactionType.income,
        );
        
        // Filter and group incomes
        final filteredIncomes = TransactionUtils.filterTransactions(
          incomes,
          searchController.text,
          selectedCategories,
        );
        final groupedIncomes = TransactionUtils.groupTransactionsByDate(
          filteredIncomes,
          localeInitialized,
        );
        final availableCategories = TransactionUtils.extractCategoriesFromTransactions(incomes);

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
            // Income list content
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              sliver: groupedIncomes.isEmpty
                  ? const SliverToBoxAdapter(child: IncomeEmptyState())
                  : TransactionDateGroup(groupedTransactions: groupedIncomes),
            ),
          ],
        );
      },
      loading: () => const TransactionLoadingState(),
      error: (error, stack) => TransactionErrorState(
        error: error,
        errorMessage: 'Erreur lors du chargement des revenus',
      ),
    );
  }

}
