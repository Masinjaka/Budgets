import 'package:budgets/core/functions/transaction_utils.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_state_widgets.dart';
import 'package:budgets/features/transactions/presentation/widgets/paginated_transaction_date_group.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_empty_state.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Expense tab content that contains the expense list
class TransactionTabContent extends ConsumerWidget {
  const TransactionTabContent({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool onScrollNotification(ScrollNotification notification) {
      if (notification is ScrollUpdateNotification) {
        if (notification.metrics.maxScrollExtent > 0 &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          ref.read(paginatedExpensesProvider.notifier).loadNextPage();
        }
      }
      return false;
    }

    // Watch paginated transaction data from provider
    final paginatedState = ref.watch(paginatedExpensesProvider);

    // Handle initial loading state
    if (paginatedState.isLoading && paginatedState.transactions.isEmpty) {
      return const TransactionListShimmerList();
    }

    // Handle error state
    if (paginatedState.errorMessage != null &&
        paginatedState.transactions.isEmpty) {
      return SizedBox.expand(
        child: TransactionErrorState(
          error: paginatedState.errorMessage!,
          errorMessage: 'Erreur lors du chargement des dépenses',
          onRetry: () => ref.read(paginatedExpensesProvider.notifier).refresh(),
        ),
      );
    }

    // Filter to only show expenses (transaction_type = 'expense')
    final allTransactions = paginatedState.transactions;
    final transactions = TransactionUtils.filterByTransactionType(
      allTransactions,
      TransactionType.expense,
    );

    final groupedTransactions = TransactionUtils.groupTransactionsByDate(
      transactions,
      true,
    );
    if (groupedTransactions.isEmpty) {
      // Empty illustration state must not be scrollable.
      return const SizedBox.expand(
        child: TransactionEmptyState(hasFilters: false),
      );
    }

    final listView = PaginatedTransactionDateGroupList(
      groupedTransactions: groupedTransactions,
      isLoadingMore: paginatedState.isLoadingMore,
      hasMore: paginatedState.hasMore,
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(8.w, 2.h, 8.w, 0),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: onScrollNotification,
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(paginatedExpensesProvider.notifier).refresh();
        },
        child: listView,
      ),
    );
  }
}
