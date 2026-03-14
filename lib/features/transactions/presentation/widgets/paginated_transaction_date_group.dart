import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

export 'transaction_list_shimmer.dart';

Widget _buildDateGroup(BuildContext context, String date, List<TransactionModel> transactions) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(0, 2.w, 0, 2.w),
        child: Text(date, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 14.5.sp)),
      ),
      ListView.separated(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: transactions.length,
        itemBuilder: (_, i) => TransactionListItem(transaction: transactions[i]),
        separatorBuilder: (_, __) => SizedBox(height: 1.h),
      ),
      SizedBox(height: 2.h),
    ],
  );
}

Widget _buildLoadMore(BuildContext context, {required bool isLoadingMore, required bool hasMore}) {
  if (isLoadingMore) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      child: Column(
        children: List.generate(3, (i) => Container(margin: EdgeInsets.only(bottom: 1.h), height: 8.h, decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(6.w)))),
      ),
    );
  }
  if (!hasMore) {
    return Padding(
      padding: EdgeInsets.all(2.h),
      child: Center(child: Text('Plus de transactions à charger', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14.sp))),
    );
  }
  return const SizedBox.shrink();
}

/// Sliver-based paginated transaction list grouped by date.
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
    if (groupedTransactions.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == groupedTransactions.length) {
            return _buildLoadMore(context, isLoadingMore: isLoadingMore, hasMore: hasMore);
          }
          final date = groupedTransactions.keys.elementAt(index);
          return _buildDateGroup(context, date, groupedTransactions[date]!);
        },
        childCount: groupedTransactions.length + (hasMore || isLoadingMore ? 1 : 0),
      ),
    );
  }
}

/// ListView-based paginated transaction list grouped by date.
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
    if (groupedTransactions.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      controller: controller,
      physics: physics,
      padding: padding ?? EdgeInsets.zero,
      itemCount: groupedTransactions.length + (hasMore || isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == groupedTransactions.length) {
          return _buildLoadMore(context, isLoadingMore: isLoadingMore, hasMore: hasMore);
        }
        final date = groupedTransactions.keys.elementAt(index);
        return _buildDateGroup(context, date, groupedTransactions[date]!);
      },
    );
  }
}
