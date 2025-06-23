import 'package:budgets/core/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:flutter/foundation.dart';

Future<List<Expense>> getExpenses() {
  return Wrapper.execute(() async {
    try {
      final response = await supabase.from('expenses').select('''
    title,
    description,
    amount,
    date,
    invoice_file,
    expense_categories (id, name )
  ''');

      if (response.isEmpty) return [];

      List<Expense> expense =
          (response as List).map((item) => Expense.fromMap(item)).toList();

      return expense;
    } catch (e, s) {
      debugPrint('$e,$s');
      rethrow;
    }
  });
}

// Add expenses
Future<void> addExpense(
    String? title, String? description, String? categoryName, double? amount) {
  return Wrapper.execute(
    () async {
      final response = await supabase.rpc(
        'insert_expense',
        params: {
          'title': title,
          'description': description,
          'category_name': categoryName,
          'amount': amount,
        },
      );

      debugPrint("Expense created: $response");
    },
  );
}
