import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/utils/amount_formatter.dart';

// Widget for displaying a single transaction item in the list
class TransactionListItem extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionListItem({super.key, required this.transaction});

  Future<bool?> _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer la transaction'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette transaction ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (transaction.id != null) {
                  try {
                    await ref
                        .read(transactionsProvider.notifier)
                        .deleteTransaction(
                            transaction.id!,
                            transaction.transactionType ??
                                TransactionType.expense);
                  } catch (e) {
                    // Handle error if needed
                    debugPrint("Error deleting transaction: $e");
                  }
                }
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(transaction.id ?? DateTime.now().toString()),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {
        DismissDirection.endToStart:
            0.7, // Requires 70% swipe to dismiss (adds resistance)
      },
      movementDuration: const Duration(
          milliseconds: 100), // Faster snap-back for resistance feel
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        final result = await _showDeleteConfirmationDialog(context, ref);
        return result ?? false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 5.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 18.sp, // Reduced from 24.sp
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: InkWell(
          borderRadius: BorderRadius.circular(4.w), // Match container radius
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) =>
                  TransactionDetailBottomSheet(transaction: transaction),
            );
          },
          child: Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Row(
              children: [
                // Icon for the transaction category
                Container(
                  width: 5.h,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Center(
                    child: Text(
                      (transaction.category != null &&
                              transaction.category!.emoji != null)
                          ? transaction.category!.emoji!
                          : '❓',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
                SizedBox(width: 1.6.h),
                // Transaction details (category and description)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.category?.name ?? 'Uncategorized',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        transaction.description ?? '',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 1.6.h),
                // Transaction amount
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
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          // fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      formatAmountValue(transaction.amount),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 14.sp,
                          ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
