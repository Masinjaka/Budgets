import 'package:budgets/core/theme.dart';
import 'package:budgets/features/transactions/domain/model/expense_model.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable widget for displaying paginated transactions by date with lazy loading
class PaginatedTransactionDateGroup extends StatelessWidget {
  final Map<String, List<Expense>> groupedTransactions;
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
          // Check if this is the last item and we should show loading indicator
          if (index == groupedTransactions.length) {
            return _buildLoadMoreIndicator();
          }

          final date = groupedTransactions.keys.elementAt(index);
          final transactions = groupedTransactions[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 2.w, 0, 2.w),
                child: Text(
                  date,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5.sp,
                  ),
                ),
              ),
              // ListView for transactions under a specific date
              ListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: transactions.length,
                itemBuilder: (context, i) {
                  return TransactionListItem(transaction: transactions[i]);
                },
                separatorBuilder: (context, i) => SizedBox(height: 1.h),
              ),
              SizedBox(height: 2.h),
            ],
          );
        },
        childCount:
            groupedTransactions.length + (hasMore || isLoadingMore ? 1 : 0),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (isLoadingMore) {
      return _buildShimmerLoading();
    }

    if (!hasMore) {
      return Padding(
        padding: EdgeInsets.all(2.h),
        child: Center(
          child: Text(
            'Plus de transactions à charger',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppTheme.secondaryDark,
      highlightColor: AppTheme.borderColorDark,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 1.h),
            height: 8.h,
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark,
              // Increased border radius for bottom lazy-loading skeletons
              borderRadius: BorderRadius.circular(6.w),
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading shimmer for initial transaction loading
class TransactionListShimmer extends StatelessWidget {
  final int itemCount;

  const TransactionListShimmer({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Shimmer.fromColors(
              baseColor: AppTheme.secondaryDark,
              highlightColor: AppTheme.borderColorDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0 || index % 3 == 0) ...[
                    // Date header shimmer (reduced width to approximate actual date text length)
                    Container(
                      width: 30.w, // previously double.infinity
                      height: 2.h,
                      margin: EdgeInsets.fromLTRB(0, 2.w, 0, 2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryDark,
                        borderRadius: BorderRadius.circular(6.w),
                      ),
                    ),
                  ],
                  // Transaction item shimmer
                  Container(
                    height: 8.h,
                    margin: EdgeInsets.only(bottom: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryDark,
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: itemCount,
        ),
      ),
    );
  }
}
