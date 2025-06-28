import 'package:budgets/api/expense_api.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_provider.g.dart';

@riverpod
class Expenses extends _$Expenses {
  @override
  Future<List<Expense>> build() async{
    return await getExpenses();
  }

  Future<void> addUserExpenses(String? title,String? description, String? categoryName,double? amount) async{
    try {
      await addExpense(title, description, categoryName, amount);

      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}