import 'package:budgets/main.dart';
import 'package:budgets/model/category_model.dart';
import 'package:budgets/provider/category_provider.dart';
import 'package:budgets/provider/expense_provider.dart';
import 'package:budgets/provider/filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseModule {
  ExpenseModule();

  // Get the date where the current user signed up
  DateTime? getUserCreationDate() {
    User? user = supabase.auth.currentUser;

    if (user != null) {
      final String createdAt = user.createdAt;
      return DateTime.parse(createdAt);
    } else {
      return null;
    }
  }

  // Filter expenses
  bool filterExpense(WidgetRef ref, List<String> selectedCategories,
      String fromDate, String toDate, BuildContext context) {
    // Update dateRange filter if they are not empty
    if (fromDate.isNotEmpty && toDate.isNotEmpty) {
      // Convert String datetimes to DateTime objects
      final startDate = DateTime.parse(fromDate);
      final endDate = DateTime.parse(toDate);

      if (endDate.isBefore(startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'La date de fin ne doit pas être antérieure à la date de début')),
        );
        return false;
      }
      final dateRange = DateTimeRange(start: startDate, end: endDate);
      ref.read(dateRangeProvider.notifier).state = dateRange;
    }

    ref.read(selectedCategoriesProvider.notifier).state = selectedCategories;

    return true;
  }

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
    String? amount, {
    required GlobalKey<FormState> formKey,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        final amountDouble = double.parse(amount!);
        await ref
            .read(expensesProvider.notifier)
            .addUserExpenses(title, description, categoryName, amountDouble);

        if (!context.mounted) return;

        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
