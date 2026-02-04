import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_api_provider.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/constants.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_incomes_provider.dart';
import 'package:budgets/features/planning/domain/providers/budget_provider.dart';
import 'package:budgets/features/planning/domain/providers/goal_provider.dart';
import 'package:budgets/features/planning/data/datasources/goal_datasource.dart'
    as goal_datasource;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_provider.g.dart';

@riverpod
class Transactions extends _$Transactions {
  @override
  Future<List<TransactionModel>> build() async {
    return await ref
        .read(transactionsApiProvider)
        .getTransactions();
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
      ref.invalidate(
          budgetsProvider); // Refresh budgets to show updated spent amounts
      ref.invalidateSelf();
    } catch (e, s) {
      debugPrint('Error in addUserTransaction: $e, StackTrace: $s');
      rethrow;
    }
  }

  Future<void> deleteTransaction(
      String transactionId,
      TransactionType transactionType, {
      TransactionModel? transaction,
  }) async {
    try {
      // Check if this is a savings category transaction and update goal
      if (transaction != null &&
          transaction.category?.name == SystemCategories.savingsCategoryName) {
        final goalName = goal_datasource
            .extractGoalNameFromDescription(transaction.description);
        if (goalName != null && transaction.amount != null) {
          // Subtract the amount from the goal (negative delta)
          await goal_datasource.updateGoalAmountByDelta(
              goalName, -transaction.amount!);
          // Refresh goals provider
          ref.invalidate(goalsProvider);
        }
      }

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
      DateTime? date, {
      TransactionModel? originalTransaction,
  }) async {
    try {
      // Check if this is a savings category transaction and handle goal amount update
      if (originalTransaction != null &&
          originalTransaction.category?.name ==
              SystemCategories.savingsCategoryName) {
        final goalName = goal_datasource
            .extractGoalNameFromDescription(originalTransaction.description);
        if (goalName != null && originalTransaction.amount != null) {
          final newAmount = double.tryParse(
                  amount?.replaceAll(',', '').replaceAll(' ', '') ?? '0') ??
              0;
          final oldAmount = originalTransaction.amount!;
          final amountDelta = newAmount - oldAmount;

          if (amountDelta != 0) {
            // Update the goal with the difference
            await goal_datasource.updateGoalAmountByDelta(goalName, amountDelta);
            // Refresh goals provider
            ref.invalidate(goalsProvider);
          }
        }
      }

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
