import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              transaction.category?.emoji ?? '',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.category?.name ?? '',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withAlpha(128),
                    size: 14,
                  ),
                  SizedBox(width: 8),
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
                      fontSize: 14,
                    ),
                  ),
                  if (transaction.date != null) ...[
                    SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha(128),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      DateFormat.Hm('fr_FR')
                          .format(transaction.date!.toLocal()),
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withAlpha(179),
                        fontSize: 14,
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
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
