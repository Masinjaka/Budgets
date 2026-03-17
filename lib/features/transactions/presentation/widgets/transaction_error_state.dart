import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionErrorState extends ConsumerWidget {
  final Object error;
  final String errorMessage;
  final VoidCallback? onRetry;

  const TransactionErrorState({
    super.key,
    required this.error,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          SizedBox(height: 2.h),
          Text(
            errorMessage,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            error.toString(),
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              if (onRetry != null) {
                onRetry!();
              } else {
                ref.invalidate(transactionsProvider);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
