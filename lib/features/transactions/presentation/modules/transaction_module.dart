import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_incomes_provider.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/features/categories/domain/providers/filter_provider.dart';
import 'package:budgets/features/categories/domain/providers/subcategories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionModule {
  TransactionModule();

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

  // Filter transactions
  bool filterTransaction(WidgetRef ref, List<String> selectedCategories,
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

  // Fetch transaction category
  Future<List<Category>> fetchCategories(WidgetRef ref) async {
    final categories = await ref.read(categoriesProvider.future);

    return categories;
  }

  // Fetch subcategories for a specific category
  Future<List<Subcategory>> fetchSubcategories(
      WidgetRef ref, String categoryId) async {
    final subcategories =
        await ref.read(subcategoriesProvider(categoryId).future);

    return subcategories;
  }

  // Add transaction
  Future<bool> addTransaction({
    // Changed return type to Future<bool>
    String? amount,
    String? description,
    String? categoryName,
    Map<String, String>? subcategoryAmounts,
    TransactionType? transactionType,
    required GlobalKey<FormState> formKey,
    required WidgetRef ref,
    // Removed BuildContext context,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        await ref.read(transactionsProvider.notifier).addUserTransaction(
              amount,
              description,
              categoryName,
              subcategoryAmounts,
              transactionType,
            );

        // Refresh the correct paginated provider based on transaction type
        if (transactionType == TransactionType.income) {
          ref.read(paginatedIncomesProvider.notifier).refresh();
        } else {
          ref.read(paginatedExpensesProvider.notifier).refresh();
        }
        return true; // Indicate success
      } catch (e) {
        debugPrint('Error adding transaction: $e');
        // Do not interact with context here
        return false; // Indicate failure
      }
    }
    return false; // Form validation failed
  }

  // Method to build subcategory amounts map for Supabase RPC
  Map<String, String> buildSubcategoryAmountsMap(
      List<Map<String, dynamic>> subcategoryAmounts) {
    final Map<String, String> subcategoryMap = {};

    for (int i = 0; i < subcategoryAmounts.length; i++) {
      var item = subcategoryAmounts[i];
      final subcategoryName = item['subcategoryName'] as String?;
      final amountController =
          item['amountController'] as TextEditingController?;

      if (subcategoryName != null &&
          subcategoryName.isNotEmpty &&
          amountController != null &&
          amountController.text.trim().isNotEmpty) {
        subcategoryMap[subcategoryName] = amountController.text.trim();
      }
    }

    return subcategoryMap;
  }

  // Method to calculate total amount from subcategories
  double calculateTotalAmount(List<Map<String, dynamic>> subcategoryAmounts) {
    double total = 0.0;

    for (var item in subcategoryAmounts) {
      final amountController =
          item['amountController'] as TextEditingController?;
      if (amountController != null && amountController.text.trim().isNotEmpty) {
        try {
          total += double.parse(amountController.text.trim());
        } catch (e) {
          debugPrint("Error parsing amount: ${amountController.text}");
        }
      }
    }

    return total;
  }

  // Method to validate subcategory amounts
  bool validateSubcategoryAmounts(
      List<Map<String, dynamic>> subcategoryAmounts) {
    if (subcategoryAmounts.isEmpty) {
      return false;
    }

    for (var item in subcategoryAmounts) {
      final subcategoryName = item['subcategoryName'] as String?;
      final amountController =
          item['amountController'] as TextEditingController?;

      if (subcategoryName == null ||
          subcategoryName.isEmpty ||
          amountController == null ||
          amountController.text.trim().isEmpty) {
        return false;
      }

      // Validate amount is a valid number
      try {
        double.parse(amountController.text.trim());
      } catch (e) {
        return false;
      }
    }

    return true;
  }

  // Create new subcategory amount item
  Map<String, dynamic> createSubcategoryAmountItem() {
    return {
      'subcategoryName': '', // Store the subcategory name as string
      'subcategoryController':
          TextEditingController(), // Controller for the text field
      'amountController': TextEditingController(),
    };
  }

  // Add subcategory amount item with animation
  void addSubcategoryAmount({
    required List<Map<String, dynamic>> subcategoryAmounts,
    required GlobalKey<AnimatedListState> listKey,
    required VoidCallback onStateChanged,
  }) {
    final newItem = createSubcategoryAmountItem();
    final insertIndex = subcategoryAmounts.length;

    debugPrint("➕ ADDING NEW SUBCATEGORY ITEM:");
    debugPrint("  - Insert index: $insertIndex");
    debugPrint("  - Total items before: ${subcategoryAmounts.length}");

    subcategoryAmounts.add(newItem);
    onStateChanged();

    debugPrint("  - Total items after: ${subcategoryAmounts.length}");

    listKey.currentState?.insertItem(insertIndex);
  }

  // Remove subcategory amount item with animation
  void removeSubcategoryAmount({
    required int index,
    required List<Map<String, dynamic>> subcategoryAmounts,
    required GlobalKey<AnimatedListState> listKey,
    required Widget Function(Map<String, dynamic>, int, Animation<double>)
        buildRemovedItem,
    required VoidCallback onStateChanged,
  }) {
    if (index >= subcategoryAmounts.length) return;

    final removedItem = subcategoryAmounts[index];

    subcategoryAmounts.removeAt(index);
    onStateChanged();

    listKey.currentState?.removeItem(
      index,
      (context, animation) => buildRemovedItem(removedItem, animation),
      duration: const Duration(milliseconds: 300),
    );

    // Dispose controllers after animation
    Future.delayed(const Duration(milliseconds: 300), () {
      removedItem['subcategoryController']?.dispose();
      removedItem['amountController']?.dispose();
    });
  }

  // Clear all subcategory amount items with staggered animation
  void clearAllSubcategoryAmounts({
    required List<Map<String, dynamic>> subcategoryAmounts,
    required GlobalKey<AnimatedListState> listKey,
    required Widget Function(Map<String, dynamic>, int, Animation<double>)
        buildRemovedItem,
    required VoidCallback onStateChanged,
  }) {
    if (subcategoryAmounts.isEmpty) return;

    // Remove items in reverse order to maintain correct indices
    for (int i = subcategoryAmounts.length - 1; i >= 0; i--) {
      final removedItem = subcategoryAmounts[i];

      listKey.currentState?.removeItem(
        i,
        (context, animation) => buildRemovedItem(removedItem, animation),
        duration: Duration(milliseconds: 200 + (i * 50)), // Staggered animation
      );

      // Dispose controllers after animation
      Future.delayed(Duration(milliseconds: 250 + (i * 50)), () {
        removedItem['subcategoryController']?.dispose();
        removedItem['amountController']?.dispose();
      });
    }

    subcategoryAmounts.clear();
    onStateChanged();
  }
}
