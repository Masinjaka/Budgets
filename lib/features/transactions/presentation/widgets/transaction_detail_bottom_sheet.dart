import 'package:budgets/core/theme.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:budgets/features/categories/domain/providers/subcategory_expenses_providers.dart';
import 'package:shimmer/shimmer.dart';
import 'package:budgets/core/utils/amount_formatter.dart';

/// Bottom sheet to display details of an expense or income
class TransactionDetailBottomSheet extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailBottomSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fix: Ensure color string starts with 0xff
    String? rawColor = transaction.category?.color;
    Color categoryColor;
    if (rawColor == null) {
      categoryColor = const Color(0xffcccccc);
    } else {
      categoryColor = Color(int.parse(rawColor, radix: 16));
    }

    if (transaction.id != null) {
      debugPrint('Transaction ID: \\${transaction.id}');
    }

    final subcategoryExpensesAsync = transaction.id != null
        ? ref.watch(subcategoryExpensesProvider(transaction.id!))
        : null;
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
                        width: 8.w,
                        height: 0.6.h,
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withAlpha(51),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                          ?.withAlpha(128),
                                      size: 14.sp),
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
                                        fontSize: 14.sp),
                                  ),
                                  if (transaction.date != null) ...[
                                    SizedBox(width: 3.w),
                                    Icon(Icons.access_time,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                            ?.withAlpha(128),
                                        size: 14.sp),
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
                                          fontSize: 14.sp),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                  // fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              formatAmountValue(transaction.amount),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                    ?.withAlpha(128),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if ((transaction.description ?? '').isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Description',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        transaction.description!,
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withAlpha(179),
                            fontSize: 14.sp),
                      ),
                    ],
                    if ((transaction.invoiceFile ?? '').isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Facture',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp),
                      ),
                      SizedBox(height: 0.5.h),
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement invoice file viewing
                        },
                        child: Text(
                          transaction.invoiceFile!,
                          style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 14.sp,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                    if (subcategoryExpensesAsync != null) ...[
                      subcategoryExpensesAsync.when(
                        data: (subcategoryExpenses) {
                          if (subcategoryExpenses.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2.h),
                              Text(
                                'Détails des sous-catégories',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp),
                              ),
                              SizedBox(height: 0.5.h),
                              ...subcategoryExpenses.map((sub) => Padding(
                                    padding: EdgeInsets.only(bottom: 0.5.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          sub.subcategory?.name ?? 'Unknown',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color
                                                  ?.withAlpha(179),
                                              fontSize: 14.sp),
                                        ),
                                        Text(
                                          formatAmountValue(sub.amount),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color
                                                  ?.withAlpha(179),
                                              fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          );
                        },
                        loading: () => _buildSubSkeleton(context),
                        error: (e, st) => const SizedBox.shrink(),
                      ),
                    ],
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
                      '/add-transaction?type=${transaction.transactionType?.value ?? 'expense'}',
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

  Padding _buildSubSkeleton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          2,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha(26) ??
                      Colors.grey.withAlpha(26),
                  highlightColor: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha(51) ??
                      Colors.grey.withAlpha(51),
                  child: Container(
                    width: 25.w,
                    height: 2.5.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha(26),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Shimmer.fromColors(
                  baseColor: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha(26) ??
                      Colors.grey.withAlpha(26),
                  highlightColor: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha(51) ??
                      Colors.grey.withAlpha(51),
                  child: Container(
                    width: 15.w,
                    height: 2.5.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha(26),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
