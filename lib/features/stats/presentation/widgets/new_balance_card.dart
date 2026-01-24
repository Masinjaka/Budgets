import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

enum BalanceCardType { expense, income }

class NewBalanceCard extends StatelessWidget {
  final BalanceCardType type;
  final double amount;

  const NewBalanceCard({
    super.key,
    required this.type,
    required this.amount,
  });

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'MGA',
      decimalDigits: 0,
    );
    return formatter.format(amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final isExpense = type == BalanceCardType.expense;
    final cardColor = isExpense
        ? Colors.red.withValues(alpha: 0.1)
        : Colors.green.withValues(alpha: 0.1);
    final amountColor = isExpense ? Colors.red : Colors.green;
    final title = isExpense ? 'Dépense' : 'Revenue';
    final icon = isExpense ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: amountColor,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
