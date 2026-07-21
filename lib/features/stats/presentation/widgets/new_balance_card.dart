import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BalanceCardType { expense, income }

class NewBalanceCard extends ConsumerWidget {
  final BalanceCardType type;
  final double amount;
  final IconData iconData;

  const NewBalanceCard({
    super.key,
    required this.type,
    required this.amount,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;
    final convertedAmount = convertFromMga(amount.abs(), rate);
    final formattedAmount = formatAmountWithCurrency(
      convertedAmount,
      currencyCode,
      preserveFraction: true,
    );
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final isExpense = type == BalanceCardType.expense;
    final title = isExpense ? 'Dépense' : 'Revenue';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Icon(iconData, color: textColor?.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 2.h),
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: textColor?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
