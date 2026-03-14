import 'package:budgets/core/theme.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/widgets/subcategory_detail_section.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.w)),
          child: Scaffold(
            body: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.w)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 8.w, height: 0.6.h,
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(51),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _TransactionHeader(
                      transaction: transaction,
                      categoryColor: categoryColor,
                      currencyCode: currencyCode,
                      rate: rate,
                    ),
                    if ((transaction.description ?? '').isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text('Description', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      SizedBox(height: 0.5.h),
                      Text(transaction.description!, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(179), fontSize: 14.sp)),
                    ],
                    if ((transaction.invoiceFile ?? '').isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text('Facture', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      SizedBox(height: 0.5.h),
                      GestureDetector(
                        onTap: () {},
                        child: Text(transaction.invoiceFile!, style: TextStyle(color: AppTheme.primaryGreen, fontSize: 14.sp, decoration: TextDecoration.underline)),
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
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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

class _TransactionHeader extends StatelessWidget {
  final TransactionModel transaction;
  final Color categoryColor;
  final String currencyCode;
  final double rate;

  const _TransactionHeader({
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
          width: 5.h, height: 5.h,
          decoration: BoxDecoration(color: categoryColor, borderRadius: BorderRadius.circular(2.w)),
          child: Center(child: Text(transaction.category?.emoji ?? '', style: TextStyle(fontSize: 18.sp))),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.category?.name ?? '', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              SizedBox(height: 0.5.h),
              Row(children: [
                Icon(Icons.calendar_today, color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128), size: 14.sp),
                SizedBox(width: 2.w),
                Text(
                  transaction.date != null ? DateFormat.yMMMMd('fr_FR').format(transaction.date!.toLocal()) : '',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(179), fontSize: 14.sp),
                ),
                if (transaction.date != null) ...[
                  SizedBox(width: 3.w),
                  Icon(Icons.access_time, color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128), size: 14.sp),
                  SizedBox(width: 1.w),
                  Text(DateFormat.Hm('fr_FR').format(transaction.date!.toLocal()), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(179), fontSize: 14.sp)),
                ],
              ]),
            ],
          ),
        ),
        Text(
          formatAmountWithCurrency(convertFromMga(transaction.amount, rate), currencyCode, preserveFraction: true),
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(128), fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ],
    );
  }
}
