import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Widget for displaying a single transaction item in the list
class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Formatting the number to include commas for thousands
    final NumberFormat currencyFormatter = NumberFormat.decimalPattern('en_US');

    return InkWell(
      borderRadius: BorderRadius.circular(5.w),
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) =>
              TransactionDetailBottomSheet(transaction: transaction),
        );
      },
      child: Container(
        padding: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Row(
          children: [
            // Icon for the transaction category
            Container(
              width: 5.h,
              height: 5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceDim,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Center(
                child: Text(
                    (transaction.category != null && transaction.category!.emoji != null)
                      ? transaction.category!.emoji!
                      : '❓',
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(width: 1.6.h),
            // Transaction details (category and description)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category!.name!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    transaction.description!,
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 1.6.h),
            // Transaction amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.5.w,
                    vertical: 0.2.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Text(
                    "MGA",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      // fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  currencyFormatter.format(transaction.amount),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 14.sp,
                      ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
