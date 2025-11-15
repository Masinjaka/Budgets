import 'package:budgets/core/utils/response_parser.dart';
import 'package:budgets/core/wrapper.dart';
import 'package:budgets/core/transaction_type.dart';
import 'package:budgets/main.dart';
import 'package:budgets/model/expense_model.dart';
import 'package:flutter/foundation.dart';

Future<List<Expense>> getExpenses() {
  return Wrapper.execute(() async {
    try {
      final response = await supabase.from('transaction').select('''
    title,
    description,
    amount,
    date,
    invoice_file,
    transaction_type,
    categories (id, name, emoji, color)
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
    String? amount, String? description, String? categoryName, Map<String, String>? subcategoryAmounts, TransactionType? transactionType) {
  return Wrapper.execute(() async {
    final response = await supabase.rpc(
      'add_expenses',
      params: {
        'amount': amount,
        'description': description,
        'category_name': categoryName,
        'tr_type': transactionType?.value ?? TransactionType.expense.value,
        'subcategories_amount': subcategoryAmounts,    
      },
    );

    final result = parseRpcAddExpenseResponse(response);

    if (!result.success) {
      throw Exception(result.errorMessage ?? 'Failed to add expense');
    }

    debugPrint("Expense created: ${response.runtimeType} -> $response");
  });
}
