import 'package:budgets/core/functions/transaction_utils.dart';
import 'package:budgets/core/functions/transaction_search_mixin.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_state_widgets.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_search_section.dart';
import 'package:budgets/features/transactions/presentation/widgets/paginated_transaction_date_group.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_empty_state.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_incomes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Income tab content with all income-related features
class IncomeTabContent extends ConsumerStatefulWidget {
  final AnimationController appBarAnimationController; // made non-null

  const IncomeTabContent({
    super.key,
    required this.appBarAnimationController,
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
    if (maxScrollExtent > 0 && currentPixels >= maxScrollExtent - 200) {
      // Load more when near bottom
      ref.read(paginatedIncomesProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch paginated income data from provider
    final paginatedState = ref.watch(paginatedIncomesProvider);

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
        errorMessage: 'Erreur lors du chargement des revenus',
        onRetry: () => ref.read(paginatedIncomesProvider.notifier).refresh(),
      );
    }

    // All transactions are already incomes in this provider
    final incomes = paginatedState.transactions;

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
    final availableCategories =
        TransactionUtils.extractCategoriesFromTransactions(incomes);

    return RefreshIndicator(
      notificationPredicate:
          isSearchFocused ? (_) => false : defaultScrollNotificationPredicate,
      onRefresh: () async {
        await ref.read(paginatedIncomesProvider.notifier).refresh();
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
          // Income list content with pagination
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            sliver: groupedIncomes.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: IncomeEmptyState(),
                  )
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
