import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/functions/transaction_utils.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_incomes_provider.dart';
import 'package:budgets/features/transactions/presentation/widgets/paginated_transaction_date_group.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_search_income_empty_state.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_empty_state.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_search_section.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionSearchPage extends ConsumerStatefulWidget {
  final String transactionType;

  const TransactionSearchPage({super.key, required this.transactionType});

  @override
  ConsumerState<TransactionSearchPage> createState() =>
      _TransactionSearchPageState();
}

class _TransactionSearchPageState extends ConsumerState<TransactionSearchPage> {
  late final TextEditingController _searchController;
  List<Category> _selectedCategories = [];

  bool get _isExpenseContext => widget.transactionType != 'income';
  bool get _hasFilters =>
      _searchController.text.trim().isNotEmpty ||
      _selectedCategories.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_isExpenseContext) {
      await ref.read(paginatedExpensesProvider.notifier).refresh();
    } else {
      await ref.read(paginatedIncomesProvider.notifier).refresh();
    }
  }

  void _loadNextPage() {
    if (_isExpenseContext) {
      ref.read(paginatedExpensesProvider.notifier).loadNextPage();
    } else {
      ref.read(paginatedIncomesProvider.notifier).loadNextPage();
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final maxExtent = notification.metrics.maxScrollExtent;
      if (maxExtent > 0 && notification.metrics.pixels >= maxExtent - 200)
        _loadNextPage();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final paginatedState = _isExpenseContext
        ? ref.watch(paginatedExpensesProvider)
        : ref.watch(paginatedIncomesProvider);

    final sourceTransactions = _isExpenseContext
        ? TransactionUtils.filterByTransactionType(
            paginatedState.transactions, TransactionType.expense)
        : paginatedState.transactions;

    final filtered = TransactionUtils.filterTransactions(
        sourceTransactions, _searchController.text, _selectedCategories);
    final grouped = TransactionUtils.groupTransactionsByDate(filtered, true);
    final availableCategories =
        TransactionUtils.extractCategoriesFromTransactions(sourceTransactions);

    return Scaffold(
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: TransactionSearchSection(
                    isSearchFocused: true,
                    onSearchFocused: () {},
                    onSearchUnfocused: context.pop,
                    onClearSearch: _searchController.clear,
                    searchController: _searchController,
                    hintText: _isExpenseContext
                        ? 'Rechercher des dépenses...'
                        : 'Rechercher des revenus...',
                    availableCategories: availableCategories,
                    selectedCategories: _selectedCategories,
                    onCategorySelectionChanged: (cats) =>
                        setState(() => _selectedCategories = cats),
                  ),
                ),
                if (paginatedState.isLoading && sourceTransactions.isEmpty)
                  const TransactionListShimmer()
                else if (paginatedState.errorMessage != null &&
                    sourceTransactions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: TransactionErrorState(
                      error: paginatedState.errorMessage!,
                      errorMessage: _isExpenseContext
                          ? 'Erreur lors du chargement des dépenses'
                          : 'Erreur lors du chargement des revenus',
                      onRetry: _refresh,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(8.w, 1.h, 8.w, 0),
                    sliver: grouped.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: _isExpenseContext
                                ? TransactionEmptyState(hasFilters: _hasFilters)
                                : TransactionSearchIncomeEmptyState(
                                    hasFilters: _hasFilters,
                                  ),
                          )
                        : PaginatedTransactionDateGroup(
                            groupedTransactions: grouped,
                            isLoadingMore: paginatedState.isLoadingMore,
                            hasMore: paginatedState.hasMore),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
