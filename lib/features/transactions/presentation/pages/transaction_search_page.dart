import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/functions/transaction_utils.dart';
import 'package:budgets/core/paths.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_incomes_provider.dart';
import 'package:budgets/features/transactions/presentation/widgets/paginated_transaction_date_group.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_empty_state.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_search_section.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionSearchPage extends ConsumerStatefulWidget {
  final String transactionType;

  const TransactionSearchPage({
    super.key,
    required this.transactionType,
  });

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
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onClearSearch() {
    _searchController.clear();
  }

  void _onCategorySelectionChanged(List<Category> categories) {
    setState(() {
      _selectedCategories = categories;
    });
  }

  Future<void> _refresh() async {
    if (_isExpenseContext) {
      await ref.read(paginatedExpensesProvider.notifier).refresh();
      return;
    }
    await ref.read(paginatedIncomesProvider.notifier).refresh();
  }

  void _loadNextPage() {
    if (_isExpenseContext) {
      ref.read(paginatedExpensesProvider.notifier).loadNextPage();
      return;
    }
    ref.read(paginatedIncomesProvider.notifier).loadNextPage();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final maxExtent = notification.metrics.maxScrollExtent;
      if (maxExtent > 0 && notification.metrics.pixels >= maxExtent - 200) {
        _loadNextPage();
      }
    }
    return false;
  }

  Widget _buildEmptyState(BuildContext context) {
    if (_isExpenseContext) {
      return TransactionEmptyState(hasFilters: _hasFilters);
    }
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String imagePath =
        isDarkMode ? AppPaths.noIncomeDark : AppPaths.noIncomeLight;
    final title =
        _hasFilters ? 'Aucun revenu' : 'Aucun revenu enregistré';
    final subtitle = _hasFilters
        ? 'Essayez de modifier votre recherche ou vos catégories'
        : 'Commencez par ajouter vos premiers revenus';

    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath)
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(
                  duration: 400.ms,
                ),
              // Title
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 22.5.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 500.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(
                    duration: 400.ms,
                    delay: 200.ms,
                  ),
      
              SizedBox(height: 2.h),
      
              // Description
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16.sp,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 500.ms,
                    delay: 400.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(
                    duration: 400.ms,
                    delay: 400.ms,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paginatedState = _isExpenseContext
        ? ref.watch(paginatedExpensesProvider)
        : ref.watch(paginatedIncomesProvider);

    final sourceTransactions = _isExpenseContext
        ? TransactionUtils.filterByTransactionType(
            paginatedState.transactions,
            TransactionType.expense,
          )
        : paginatedState.transactions;

    final filteredTransactions = TransactionUtils.filterTransactions(
      sourceTransactions,
      _searchController.text,
      _selectedCategories,
    );

    final groupedTransactions = TransactionUtils.groupTransactionsByDate(
      filteredTransactions,
      true,
    );

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
                    onClearSearch: _onClearSearch,
                    searchController: _searchController,
                    hintText: _isExpenseContext
                        ? 'Rechercher des dépenses...'
                        : 'Rechercher des revenus...',
                    availableCategories: availableCategories,
                    selectedCategories: _selectedCategories,
                    onCategorySelectionChanged: _onCategorySelectionChanged,
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
                    padding: EdgeInsets.fromLTRB(6.w, 1.h, 6.w, 0),
                    sliver: groupedTransactions.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildEmptyState(context),
                          )
                        : PaginatedTransactionDateGroup(
                            groupedTransactions: groupedTransactions,
                            isLoadingMore: paginatedState.isLoadingMore,
                            hasMore: paginatedState.hasMore,
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
