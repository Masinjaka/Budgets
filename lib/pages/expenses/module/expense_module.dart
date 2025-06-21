import 'package:budgets/model/category_model.dart';
import 'package:budgets/provider/category_provider.dart';
import 'package:budgets/provider/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExpenseModule {
  ExpenseModule();

  // Fetch expense category
  Future<List<Category>> fetchCategories(WidgetRef ref) async {
    final categories = await ref.read(categoriesProvider.future);

    return categories;
  }

  // Add expense
  Future<void> addExpense(
    String? title,
    String? description,
    String? categoryName,
    double? amount, {
    required GlobalKey<FormState> formKey,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        await ref
            .read(expensesProvider.notifier)
            .addUserExpenses(title, description, categoryName, amount);

        if(!context.mounted) return;

        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
