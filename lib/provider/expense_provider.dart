import 'package:budgets/api/expense_api.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_provider.g.dart';

@riverpod
class Expenses extends _$Expenses {
  @override
  Future<List<Expense>> build() async{
    return await getExpenses();
  }

  Future<void> addUserExpenses(String? amount, String? description, String? categoryName, Map<String, String>? subcategoryAmounts) async{
    try {
      await addExpense(amount, description, categoryName, subcategoryAmounts);

      ref.invalidateSelf();
    } catch (e,s) {
      debugPrint('Error in addUserExpenses: $e, StackTrace: $s');
      rethrow;
    }
  }
}