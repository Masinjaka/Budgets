import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          CustomButton(
            text: 'Réessayer',
            width: 128,
            onPressed: () {
              if (onRetry != null) {
                onRetry!();
              } else {
                ref.invalidate(transactionsProvider);
              }
            },
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
