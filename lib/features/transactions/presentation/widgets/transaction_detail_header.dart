import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionDetailHeader extends StatelessWidget {
  final TransactionModel transaction;
  final Color categoryColor;
  final String currencyCode;
  final double rate;

  const TransactionDetailHeader({
    super.key,
    required this.transaction,
    required this.categoryColor,
    required this.currencyCode,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5.h,
          height: 5.h,
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Center(
            child: Text(
              transaction.category?.emoji ?? '',
              style: TextStyle(fontSize: 18.sp),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.category?.name ?? '',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withAlpha(128),
                    size: 14.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    transaction.date != null
                        ? DateFormat.yMMMMd('fr_FR')
                            .format(transaction.date!.toLocal())
                        : '',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha(179),
                      fontSize: 14.sp,
                    ),
                  ),
                  if (transaction.date != null) ...[
                    SizedBox(width: 3.w),
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha(128),
                      size: 14.sp,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      DateFormat.Hm('fr_FR')
                          .format(transaction.date!.toLocal()),
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withAlpha(179),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Text(
          formatAmountWithCurrency(
            convertFromMga(transaction.amount, rate),
            currencyCode,
            preserveFraction: true,
          ),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128),
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }
}
