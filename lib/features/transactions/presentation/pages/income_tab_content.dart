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
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent > 0 &&
          notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
        ref.read(paginatedIncomesProvider.notifier).loadNextPage();
      }
    }
    return false;
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

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: RefreshIndicator(
        notificationPredicate:
            isSearchFocused ? (_) => false : defaultScrollNotificationPredicate,
        onRefresh: () async {
          await ref.read(paginatedIncomesProvider.notifier).refresh();
        },
        child: CustomScrollView(
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
      ),
    );
  }
}
