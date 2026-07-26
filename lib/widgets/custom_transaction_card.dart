import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    final currencyState = ref.watch(currencyControllerProvider);
    final currency = currencyState.asData?.value;
    final amountMga = parseAmountInput(widget.amount);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceDim,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(
                        child: Text(
                          widget.categoryEmoji,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
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
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          DateFormat('dd MMM yyyy', 'fr').format(widget.date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 15,
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
              if (currency == null)
                textSkeleton(context, 80, 16)
              else
                Text(
                  formatAmountWithCurrency(
                    convertFromMga(amountMga, currency.rateFor(currency.code)),
                    currency.code,
                    preserveFraction: true,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
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
