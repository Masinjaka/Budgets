import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/widgets/paginated_transaction_date_group_helpers.dart';
import 'package:flutter/material.dart';

export 'paginated_transaction_date_group_list.dart';
export 'transaction_list_shimmer.dart';

class PaginatedTransactionDateGroup extends StatelessWidget {
  final Map<String, List<TransactionModel>> groupedTransactions;
  final bool isLoadingMore;
  final bool hasMore;

  const PaginatedTransactionDateGroup({
    super.key,
    required this.groupedTransactions,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (groupedTransactions.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == groupedTransactions.length) {
            return buildLoadMoreIndicator(
              context,
              isLoadingMore: isLoadingMore,
              hasMore: hasMore,
            );
          }
          final date = groupedTransactions.keys.elementAt(index);
          return buildPaginatedDateGroup(
            context,
            date,
            groupedTransactions[date]!,
          );
        },
        childCount:
            groupedTransactions.length + (hasMore || isLoadingMore ? 1 : 0),
      ),
    );
  }
}
