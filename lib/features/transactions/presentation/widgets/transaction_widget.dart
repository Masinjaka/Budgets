import 'dart:async';

import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_detail_bottom_sheet.dart';
import 'package:budgets/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:vibration/vibration.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/core/currency/currency_provider.dart';

// Widget for displaying a single transaction item in the list
class TransactionListItem extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  ConsumerState<TransactionListItem> createState() =>
      _TransactionListItemState();
}

class _TransactionListItemState extends ConsumerState<TransactionListItem> {
  bool _hasTriggeredHalfSwipeHaptic = false;
  bool _canVibrate = true;
  double _swipeProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeVibrationSupport();
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) {
    return showDeleteConfirmationDialog(
      context: context,
      title: 'Supprimer la transaction',
      message: 'Êtes-vous sûr de vouloir supprimer cette transaction ?',
    );
  }

  Future<void> _initializeVibrationSupport() async {
    try {
      final canVibrate = await Vibration.hasVibrator();
      _canVibrate = canVibrate == true;
    } catch (_) {
      _canVibrate = false;
    }
  }

  Future<void> _triggerHalfSwipeVibration() async {
    if (!_canVibrate) return;
    try {
      await Vibration.vibrate(duration: 30);
    } catch (_) {
      // Ignore vibration errors to avoid interrupting swipe interactions.
    }
  }

  void _handleDismissUpdate(DismissUpdateDetails details) {
    final progress = details.progress.clamp(0.0, 1.0);

    if ((progress - _swipeProgress).abs() > 0.01) {
      setState(() {
        _swipeProgress = progress;
      });
    }

    if (!_hasTriggeredHalfSwipeHaptic && progress >= 0.5) {
      unawaited(_triggerHalfSwipeVibration());
      _hasTriggeredHalfSwipeHaptic = true;
      return;
    }

    if (_hasTriggeredHalfSwipeHaptic && progress < 0.2) {
      _hasTriggeredHalfSwipeHaptic = false;
    }
  }

  void _resetSwipeFeedbackState() {
    if (_hasTriggeredHalfSwipeHaptic || _swipeProgress > 0) {
      if (mounted) {
        setState(() {
          _hasTriggeredHalfSwipeHaptic = false;
          _swipeProgress = 0;
        });
      } else {
        _hasTriggeredHalfSwipeHaptic = false;
        _swipeProgress = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final cardBorderRadius = BorderRadius.circular(4.w);
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;
    final displayAmount = convertFromMga(transaction.amount, rate);

    return ClipRRect(
      borderRadius: cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: Key(transaction.id ?? DateTime.now().toString()),
        direction: DismissDirection.endToStart,
        onUpdate: _handleDismissUpdate,
        dismissThresholds: const {
          DismissDirection.endToStart:
              0.7, // Requires 70% swipe to dismiss (adds resistance)
        },
        movementDuration: const Duration(
            milliseconds: 100), // Faster snap-back for resistance feel
        confirmDismiss: (direction) async {
          final shouldDelete = await _showDeleteConfirmationDialog(context);
          if (!shouldDelete || transaction.id == null) {
            _resetSwipeFeedbackState();
            return false;
          }

          try {
            await ref.read(transactionsProvider.notifier).deleteTransaction(
                  transaction.id!,
                  transaction.transactionType ?? TransactionType.expense,
                  transaction: transaction,
                );
            _resetSwipeFeedbackState();
            return true;
          } catch (e) {
            debugPrint("Error deleting transaction: $e");
            _resetSwipeFeedbackState();
            return false;
          }
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 5.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Supprimer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 1.5.w),
              Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 18.sp,
              ),
            ],
          ),
        ).animate(target: _swipeProgress).custom(
              duration: 120.ms,
              curve: Curves.linear,
              builder: (context, value, child) => DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.lerp(Colors.orange, Colors.red, value),
                  borderRadius: cardBorderRadius,
                ),
                child: child,
              ),
            ),
        child: Material(
          color: Theme.of(context).cardColor,
          borderRadius: cardBorderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: cardBorderRadius, // Match container radius
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) =>
                    TransactionDetailBottomSheet(transaction: transaction),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(2.5.w),
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
                  Text(
                    formatAmountWithCurrency(displayAmount, currencyCode),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 14.sp,
                        ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
