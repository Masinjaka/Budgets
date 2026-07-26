import 'package:budgets/core/functions/transaction_utils.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_state_widgets.dart';
import 'package:budgets/features/transactions/presentation/widgets/paginated_transaction_date_group.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_empty_state.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_incomes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Income tab content with all income-related features
class IncomeTabContent extends ConsumerWidget {
  const IncomeTabContent({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool onScrollNotification(ScrollNotification notification) {
      if (notification is ScrollUpdateNotification) {
        if (notification.metrics.maxScrollExtent > 0 &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          ref.read(paginatedIncomesProvider.notifier).loadNextPage();
        }
      }
      return false;
    }

    // Watch paginated income data from provider
    final paginatedState = ref.watch(paginatedIncomesProvider);

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
          errorMessage: 'Erreur lors du chargement des revenus',
          onRetry: () => ref.read(paginatedIncomesProvider.notifier).refresh(),
        ),
      );
    }

    // All transactions are already incomes in this provider
    final incomes = paginatedState.transactions;

    final groupedIncomes = TransactionUtils.groupTransactionsByDate(
      incomes,
      true,
    );
    if (groupedIncomes.isEmpty) {
      // Empty illustration state must not be scrollable.
      return const SizedBox.expand(
        child: IncomeEmptyState(),
      );
    }

    final listView = PaginatedTransactionDateGroupList(
      groupedTransactions: groupedIncomes,
      isLoadingMore: paginatedState.isLoadingMore,
      hasMore: paginatedState.hasMore,
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(32, 16, 32, 0),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: onScrollNotification,
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(paginatedIncomesProvider.notifier).refresh();
        },
        child: listView,
      ),
    );
  }
}
