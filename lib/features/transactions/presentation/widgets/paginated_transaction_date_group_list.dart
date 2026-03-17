import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/widgets/paginated_transaction_date_group_helpers.dart';
import 'package:flutter/material.dart';

class PaginatedTransactionDateGroupList extends StatelessWidget {
  final Map<String, List<TransactionModel>> groupedTransactions;
  final bool isLoadingMore;
  final bool hasMore;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const PaginatedTransactionDateGroupList({
    super.key,
    required this.groupedTransactions,
    required this.isLoadingMore,
    required this.hasMore,
    this.controller,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (groupedTransactions.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.builder(
      controller: controller,
      physics: physics,
      padding: padding ?? EdgeInsets.zero,
      itemCount:
          groupedTransactions.length + (hasMore || isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
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
    );
  }
}
