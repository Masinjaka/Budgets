import 'package:budgets/model/expense_model.dart';
import 'package:budgets/widgets/expense_widgets/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Reusable widget for displaying grouped transactions by date
class TransactionDateGroup extends StatelessWidget {
  final Map<String, List<Expense>> groupedTransactions;

  const TransactionDateGroup({
    super.key,
    required this.groupedTransactions,
  });

  @override
  Widget build(BuildContext context) {
    if (groupedTransactions.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
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
        childCount: groupedTransactions.length,
      ),
    );
  }
}
