import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/widgets/skeleton/home_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Jumbotron extends ConsumerWidget {
  const Jumbotron({
    super.key,
  });

  /// Calculates the balance for the current month (income - expenses)
  double _calculateCurrentMonthBalance(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (final transaction in transactions) {
      if (transaction.date != null &&
          transaction.date!.year == currentYear &&
          transaction.date!.month == currentMonth) {
        final amount = transaction.amount ?? 0.0;

        if (transaction.transactionType == TransactionType.income) {
          totalIncome += amount;
        } else if (transaction.transactionType == TransactionType.expense) {
          totalExpenses += amount;
        }
      }
    }

    return totalIncome - totalExpenses;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTransactions = ref.watch(transactionsProvider);

    return Container(
      height: 16.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 2.h,
            left: 2.h,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Reste à dépenser',
                style: TextStyle(
                  fontSize: 15.5.sp,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          Positioned(
            top: 2.h,
            right: 2.h,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.w),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Text(
                  'MGA',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 3.h,
            bottom: 3.h,
            left: 2.h,
            child: Align(
              alignment: Alignment.centerLeft,
              child: asyncTransactions.when(
                data: (transactions) {
                  final balance = _calculateCurrentMonthBalance(transactions);
                  final isNegative = balance < 0;

                  return Text(
                    '${isNegative ? '-' : ''}${formatAmount(balance.abs().toString())}',
                    style: TextStyle(
                      fontSize: 22.sp,
                      color: isNegative
                          ? Colors.red
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
                loading: () => const JumbotronAmountSkeleton(),
                error: (error, stack) => Text(
                  'Erreur',
                  style: TextStyle(
                    fontSize: 25.sp,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
