import 'package:budgets/features/transactions/data/datasource/transaction_api.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_provider.g.dart';

@riverpod
class Transactions extends _$Transactions {
  @override
  Future<List<TransactionModel>> build() async {
    return await getTransactions();
  }

  Future<void> addUserTransaction(
      String? amount,
      String? description,
      String? categoryName,
      Map<String, String>? subcategoryAmounts,
      TransactionType? transactionType) async {
    try {
      await addTransaction(amount, description, categoryName,
          subcategoryAmounts, transactionType);
      // ignore: unused_local_variable
      final paginated = ref.refresh(paginatedTransactionsProvider);
      ref.invalidateSelf();
    } catch (e, s) {
      debugPrint('Error in addUserTransaction: $e, StackTrace: $s');
      rethrow;
    }
  }
}
