import 'package:budgets/core/functions/transaction_utils.dart';
import 'package:budgets/core/functions/transaction_search_mixin.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_state_widgets.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_search_section.dart';
import 'package:budgets/features/transactions/presentation/widgets/paginated_transaction_date_group.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_empty_states.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
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
        errorMessage: 'Erreur lors du chargement des revenus',
      );
    }

    // Filter to only show incomes (transaction_type = 'income')
    final allTransactions = paginatedState.transactions;
    final incomes = TransactionUtils.filterByTransactionType(
      allTransactions, 
      TransactionType.income,
    );
    
    // Filter and group incomes based on search/filters
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
          // Income list content with pagination
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            sliver: groupedIncomes.isEmpty
                ? const SliverToBoxAdapter(child: IncomeEmptyState())
                : PaginatedTransactionDateGroup(
                    groupedTransactions: groupedIncomes,
                    isLoadingMore: paginatedState.isLoadingMore,
                    hasMore: paginatedState.hasMore,
                  ),
          ),
        ],
      ),
    );
  }

}
