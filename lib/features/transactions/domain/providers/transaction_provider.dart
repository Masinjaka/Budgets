import 'package:budgets/features/transactions/data/datasource/transaction_api.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_incomes_provider.dart';
// Keep this import if still needed
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_provider.g.dart';

@riverpod
class Transactions extends _$Transactions {
  @override
  Future<List<TransactionModel>> build() async {
    return await ref
        .read(transactionsApiProvider)
        .getTransactions(); // Modified
  }

  Future<void> addUserTransaction(
      String? amount,
      String? description,
      String? categoryName,
      Map<String, String>? subcategoryAmounts,
      TransactionType? transactionType) async {
    try {
      await ref.read(transactionsApiProvider).addTransaction(
          // Modified
          amount,
          description,
          categoryName,
          subcategoryAmounts,
          transactionType);
      // ignore: unused_result
      // ref.read(paginatedTransactionsProvider.notifier).refresh();
      ref.invalidateSelf();
    } catch (e, s) {
      debugPrint('Error in addUserTransaction: $e, StackTrace: $s');
      rethrow;
    }
  }

  Future<void> deleteTransaction(
      String transactionId, TransactionType transactionType) async {
    try {
      await ref.read(transactionsApiProvider).deleteTransaction(transactionId);

      // Refresh the correct paginated provider based on transaction type
      if (transactionType == TransactionType.income) {
        ref.read(paginatedIncomesProvider.notifier).refresh();
      } else {
        ref.read(paginatedExpensesProvider.notifier).refresh();
      }

      ref.invalidateSelf();
    } catch (e, s) {
      debugPrint('Error in deleteTransaction: $e, StackTrace: $s');
      rethrow;
    }
  }

  Future<void> editTransaction(
      String transactionId,
      String? amount,
      String? description,
      String? categoryName,
      Map<String, String>? subcategoryAmounts,
      TransactionType? transactionType,
      DateTime? date) async {
    try {
      await ref.read(transactionsApiProvider).editTransaction(
            transactionId,
            amount,
            description,
            categoryName,
            subcategoryAmounts,
            transactionType,
            date,
          );

      // Refresh relevant providers
      if (transactionType == TransactionType.income) {
        ref.read(paginatedIncomesProvider.notifier).refresh();
      } else {
        ref.read(paginatedExpensesProvider.notifier).refresh();
      }

      ref.invalidateSelf();
    } catch (e, s) {
      debugPrint('Error in editTransaction: $e, StackTrace: $s');
      rethrow;
    }
  }
}
