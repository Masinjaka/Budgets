import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/widgets/subcategory_detail_section.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_detail_header.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:budgets/core/currency/currency_provider.dart';

class TransactionDetailBottomSheet extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailBottomSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;

    String? rawColor = transaction.category?.color;
    final categoryColor = rawColor == null
        ? const Color(0xffcccccc)
        : Color(int.parse(rawColor, radix: 16));

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          child: Scaffold(
            body: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 32,
                        height: 4.8,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TransactionDetailHeader(
                      transaction: transaction,
                      categoryColor: categoryColor,
                      currencyCode: currencyCode,
                      rate: rate,
                    ),
                    if ((transaction.description ?? '').isNotEmpty) ...[
                      SizedBox(height: 16),
                      Text('Description',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      SizedBox(height: 4),
                      Text(transaction.description!,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withAlpha(179),
                              fontSize: 14)),
                    ],
                    if ((transaction.invoiceFile ?? '').isNotEmpty) ...[
                      SizedBox(height: 16),
                      Text('Facture',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {},
                        child: Text(transaction.invoiceFile!,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                    if (transaction.id != null)
                      SubcategoryDetailSection(
                        transactionId: transaction.id!,
                        currencyCode: currencyCode,
                        rate: rate,
                      ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: CustomButton(
                  text: 'Modifier',
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push(
                      '/edit-transaction?type=${transaction.transactionType?.value ?? 'expense'}',
                      extra: transaction,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
