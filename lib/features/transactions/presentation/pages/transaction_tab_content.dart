import 'package:budgets/core/functions/transaction_utils.dart';
import 'package:budgets/core/functions/transaction_search_mixin.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_state_widgets.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_search_section.dart';
import 'package:budgets/features/transactions/presentation/widgets/paginated_transaction_date_group.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_empty_state.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Transaction tab content that contains the search bar and transaction list
class TransactionTabContent extends ConsumerStatefulWidget {
  final AnimationController appBarAnimationController;

  const TransactionTabContent({
    super.key,
    required this.appBarAnimationController,
  });

  @override
  ConsumerState<TransactionTabContent> createState() =>
      _TransactionTabContentState();
}

class _TransactionTabContentState extends ConsumerState<TransactionTabContent>
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
    if (maxScrollExtent > 0 && currentPixels >= maxScrollExtent - 200) {
      // Load more when near bottom
      ref.read(paginatedTransactionsProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch paginated transaction data from provider
    final paginatedState = ref.watch(paginatedTransactionsProvider);

    // Handle initial loading state
    if (paginatedState.isLoading && paginatedState.transactions.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
    if (paginatedState.errorMessage != null &&
        paginatedState.transactions.isEmpty) {
      return TransactionErrorState(
        error: paginatedState.errorMessage!,
        errorMessage: 'Erreur lors du chargement des dépenses',
        onRetry: () =>
            ref.read(paginatedTransactionsProvider.notifier).refresh(),
      );
    }

    // Filter to only show expenses (transaction_type = 'expense')
    final allTransactions = paginatedState.transactions;
    final transactions = TransactionUtils.filterByTransactionType(
      allTransactions,
      TransactionType.expense,
    );

    // Filter and group expenses based on search/filters
    final filteredTransactions = TransactionUtils.filterTransactions(
      transactions,
      searchController.text,
      selectedCategories,
    );
    final groupedTransactions = TransactionUtils.groupTransactionsByDate(
      filteredTransactions,
      localeInitialized,
    );
    final availableCategories =
        TransactionUtils.extractCategoriesFromTransactions(transactions);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(paginatedTransactionsProvider.notifier).refresh();
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Search bar section
          SliverToBoxAdapter(
            child: TransactionSearchSection(
              isSearchFocused: isSearchFocused,
              onSearchFocused: () =>
                  onSearchFocused(widget.appBarAnimationController),
              onSearchUnfocused: () =>
                  onSearchUnfocused(widget.appBarAnimationController),
              onClearSearch: onClearSearch,
              searchController: searchController,
              hintText: 'Rechercher...',
              availableCategories: availableCategories,
              selectedCategories: selectedCategories,
              onCategorySelectionChanged: onCategorySelectionChanged,
            ),
          ),
          // Transaction list content with pagination
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            sliver: groupedTransactions.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: TransactionEmptyState(hasFilters: hasFilters),
                  )
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
