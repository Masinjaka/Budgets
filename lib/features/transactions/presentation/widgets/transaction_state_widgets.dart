import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Reusable loading state widget for transaction screens
class TransactionLoadingState extends StatelessWidget {
  const TransactionLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

/// Reusable error state widget for transaction screens
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
                // Fallback for legacy consumers
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
