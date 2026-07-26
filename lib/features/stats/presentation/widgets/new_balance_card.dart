import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:flutter/material.dart';
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: textColor?.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 16),
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
