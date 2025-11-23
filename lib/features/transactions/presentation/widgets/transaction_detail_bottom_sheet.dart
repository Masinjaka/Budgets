import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:budgets/features/categories/domain/providers/subcategory_expenses_providers.dart';
import 'package:shimmer/shimmer.dart';

/// Bottom sheet to display details of an expense or income
class TransactionDetailBottomSheet extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailBottomSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NumberFormat currencyFormatter = NumberFormat.decimalPattern('en_US');
    final isExpense = transaction.transactionType == TransactionType.expense;
    final color = isExpense ? Colors.redAccent : AppTheme.primaryGreen;
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
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 10.w,
                    height: 0.7.h,
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7.h,
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Center(
                        child: Text(
                          transaction.category?.emoji ?? '',
                          style: TextStyle(fontSize: 20.sp),
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            transaction.title ?? '',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'MGA',
                          style: TextStyle(
                            color: color,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          currencyFormatter.format(transaction.amount),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.5.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Colors.white54, size: 15.sp),
                    SizedBox(width: 2.w),
                    Text(
                      transaction.date != null
                          ? DateFormat.yMMMMd('fr_FR')
                              .format(transaction.date!.toLocal())
                          : '',
                      style: TextStyle(color: Colors.white70, fontSize: 15.sp),
                    ),
                    if (transaction.date != null) ...[
                      SizedBox(width: 3.w),
                      Icon(Icons.access_time,
                          color: Colors.white54, size: 15.sp),
                      SizedBox(width: 1.w),
                      Text(
                        DateFormat.Hm('fr_FR')
                            .format(transaction.date!.toLocal()),
                        style:
                            TextStyle(color: Colors.white70, fontSize: 15.sp),
                      ),
                    ],
                  ],
                ),
                if ((transaction.description ?? '').isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Description',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    transaction.description!,
                    style: TextStyle(color: Colors.white70, fontSize: 15.sp),
                  ),
                ],
                if ((transaction.invoiceFile ?? '').isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Facture',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp),
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
                          fontSize: 15.sp,
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp),
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
                                          color: Colors.white70,
                                          fontSize: 15.sp),
                                    ),
                                    Text(
                                      currencyFormatter.format(sub.amount),
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 15.sp),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      );
                    },
                    loading: () => _buildSubSkeleton(),
                    error: (e, st) => const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  _buildSubSkeleton() {
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
                  baseColor: Colors.white24,
                  highlightColor: Colors.white38,
                  child: Container(
                    width: 25.w,
                    height: 2.5.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Shimmer.fromColors(
                  baseColor: Colors.white24,
                  highlightColor: Colors.white38,
                  child: Container(
                    width: 15.w,
                    height: 2.5.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
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
