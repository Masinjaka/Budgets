import 'package:budgets/core/functions/transaction_utils.dart';
import 'package:budgets/core/functions/transaction_search_mixin.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/expense/presentation/widgets/transaction_state_widgets.dart';
import 'package:budgets/features/expense/presentation/widgets/transaction_search_section.dart';
import 'package:budgets/features/expense/presentation/widgets/paginated_transaction_date_group.dart';
import 'package:budgets/features/expense/presentation/widgets/transaction_empty_states.dart';
import 'package:budgets/provider/paginated_expenses_provider.dart';
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

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Add guards to prevent scroll position errors
    if (!_scrollController.hasClients) return;
    if (!_scrollController.position.hasContentDimensions) return;
    if (!_scrollController.position.hasPixels) return;
    
    final position = _scrollController.position;
    final maxScrollExtent = position.maxScrollExtent;
    final currentPixels = position.pixels;
    
    // Only trigger load more if there's actual scrollable content
    if (maxScrollExtent > 0 && 
        currentPixels >= maxScrollExtent - 200) {
      // Load more when near bottom
      ref.read(paginatedExpensesProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch paginated expense data from provider
    final paginatedState = ref.watch(paginatedExpensesProvider);
    
    // Handle initial loading state
    if (paginatedState.isLoading && paginatedState.transactions.isEmpty) {
      return CustomScrollView(
        slivers: [
          // Search bar section (disabled during loading)
          SliverToBoxAdapter(
            child: TransactionSearchSection(
              isSearchFocused: false,
              onSearchFocused: () {},
              onSearchUnfocused: () {},
              onClearSearch: () {},
              searchController: searchController,
              hintText: 'Rechercher...',
              availableCategories: const [],
              selectedCategories: const [],
              onCategorySelectionChanged: (categories) {},
            ),
          ),
          // Loading shimmer
          const TransactionListShimmer(),
        ],
      );
    }

    // Handle error state
    if (paginatedState.errorMessage != null && paginatedState.transactions.isEmpty) {
      return TransactionErrorState(
        error: paginatedState.errorMessage!,
        errorMessage: 'Erreur lors du chargement des dépenses',
      );
    }

    // Filter to only show expenses (transaction_type = 'expense')
    final allExpenses = paginatedState.transactions;
    final expenses = TransactionUtils.filterByTransactionType(
      allExpenses, 
      TransactionType.expense,
    );
    
    // Filter and group expenses based on search/filters
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

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(paginatedExpensesProvider.notifier).refresh();
      },
      child: CustomScrollView(
        controller: _scrollController,
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
          // Expense list content with pagination
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            sliver: groupedTransactions.isEmpty
                ? SliverToBoxAdapter(child: ExpenseEmptyState(hasFilters: hasFilters))
                : PaginatedTransactionDateGroup(
                    groupedTransactions: groupedTransactions,
                    isLoadingMore: paginatedState.isLoadingMore,
                    hasMore: paginatedState.hasMore,
                  ),
          ),
        ],
      ),
    );
  }
}
