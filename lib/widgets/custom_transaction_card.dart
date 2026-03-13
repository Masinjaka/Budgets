import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionTile extends ConsumerStatefulWidget {
  const TransactionTile({
    super.key,
    required this.designation,
    required this.category,
    required this.amount,
    required this.date,
    required this.categoryColor,
    required this.categoryEmoji,
    required this.description,
    required this.categoryId,
    required this.transactionType,
  });

  final String designation;
  final String category;
  final String amount;
  final DateTime date;
  final Color categoryColor; // Default color, can be customized
  final String categoryEmoji;
  final String description;
  final String categoryId;
  final String transactionType;

  @override
  ConsumerState<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends ConsumerState<TransactionTile> {
  // Removed local formatting helpers in favor of shared utils

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;
    final amountMga = parseAmountInput(widget.amount);
    final displayAmount = convertFromMga(amountMga, rate);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4.w),
      ),
      // Use LayoutBuilder to get tile width and constrain description to half
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double textMaxWidth = constraints.maxWidth * 0.5;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceDim,
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Center(
                        child: Text(
                          widget.categoryEmoji,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  // Constrain text column to half of the tile width to trigger earlier ellipsis
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: textMaxWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          widget.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ...existing code...
              Text(
                formatAmountWithCurrency(
                  displayAmount,
                  currencyCode,
                  preserveFraction: true,
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: widget.transactionType == 'expense'
                          ? const Color.fromARGB(255, 215, 120, 113)
                          : const Color.fromARGB(255, 82, 149, 84),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
