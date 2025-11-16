import 'package:budgets/api/expense_api.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_provider.g.dart';


@riverpod
class Expenses extends _$Expenses {
  @override
  Future<List<Expense>> build() async{
    return await getExpenses();
  }

  Future<void> addUserExpenses(String? amount, String? description, String? categoryName, Map<String, String>? subcategoryAmounts, TransactionType? transactionType) async{
    try {
      await addExpense(amount, description, categoryName, subcategoryAmounts, transactionType);
      // ignore: unused_local_variable
      final paginated = ref.refresh(paginatedExpensesProvider);
      ref.invalidateSelf();
    } catch (e,s) {
      debugPrint('Error in addUserExpenses: $e, StackTrace: $s');
      rethrow;
    }
  }
}