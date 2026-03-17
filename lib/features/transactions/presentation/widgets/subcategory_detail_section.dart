import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/categories/domain/providers/subcategory_expenses_providers.dart';
import 'package:budgets/features/transactions/presentation/widgets/subcategory_detail_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Shows subcategory breakdown for a transaction (data, loading skeleton, or nothing).
class SubcategoryDetailSection extends ConsumerWidget {
  final String transactionId;
  final String currencyCode;
  final double rate;

  const SubcategoryDetailSection({
    super.key,
    required this.transactionId,
    required this.currencyCode,
    required this.rate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(subcategoryExpensesProvider(transactionId));
    return async.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            Text('Détails des sous-catégories',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp)),
            SizedBox(height: 1.5.h),
            ...items.map((sub) => Padding(
                  padding: EdgeInsets.only(bottom: 0.5.h),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceDim,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(sub.subcategory?.name ?? 'Unknown',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                    ?.withAlpha(179),
                                fontSize: 14.sp)),
                        Text(
                          formatAmountWithCurrency(
                              convertFromMga(sub.amount, rate), currencyCode,
                              preserveFraction: true),
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
                  ),
                )),
          ],
        );
      },
      loading: () => const SubcategoryDetailSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
