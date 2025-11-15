import 'package:budgets/core/theme.dart';
import 'package:budgets/provider/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Reusable loading state widget for transaction screens
class TransactionLoadingState extends StatelessWidget {
  const TransactionLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryGreen,
      ),
    );
  }
}

/// Reusable error state widget for transaction screens
class TransactionErrorState extends ConsumerWidget {
  final Object error;
  final String errorMessage;

  const TransactionErrorState({
    super.key,
    required this.error,
    required this.errorMessage,
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
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            error.toString(),
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(expensesProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: AppTheme.secondaryDark,
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
