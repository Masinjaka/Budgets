import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/categories/domain/providers/subcategory_expenses_providers.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/modules/transaction_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionInitData {
  final List<Category> categories;
  final Category? selectedCategory;
  final List<Subcategory> subcategories;
  final bool isMultipleAmounts;
  final List<Map<String, dynamic>> subcategoryAmounts;
  final String? amountText;

  const TransactionInitData({
    required this.categories,
    this.selectedCategory,
    this.subcategories = const [],
    this.isMultipleAmounts = false,
    this.subcategoryAmounts = const [],
    this.amountText,
  });
}

class TransactionCreationInitializer {
  static Future<TransactionInitData> initialize({
    required WidgetRef ref,
    required bool isEditMode,
    required TransactionModel? transaction,
    required TransactionType transactionType,
    required TransactionModule module,
  }) async {
    final currencyState = await ref.read(currencyControllerProvider.future);
    final rate = currencyState.rateFor(currencyState.code);
    final decimals = currencyState.code == 'MGA' ? 0 : 2;

    String formatAmount(double value) {
      final fixed = value.toStringAsFixed(decimals);
      return fixed.contains('.') ? fixed.replaceAll(RegExp(r'\.?0+$'), '') : fixed;
    }

    final allCategories = await module.fetchCategories(ref);
    final filteredCategories = allCategories.where((c) => c.transactionType == transactionType).toList();

    if (!isEditMode || transaction == null) {
      return TransactionInitData(categories: filteredCategories);
    }

    // Edit mode: pre-select category
    Category? selectedCategory;
    if (transaction.category != null) {
      selectedCategory = filteredCategories.firstWhere(
        (cat) => cat.id == transaction.category!.id,
        orElse: () => filteredCategories.first,
      );
    }

    // Edit mode: check for subcategory expenses
    if (transaction.id != null) {
      try {
        final subcategoryExpenses = await ref.read(subcategoryExpensesProvider(transaction.id!).future);
        if (subcategoryExpenses.isNotEmpty) {
          List<Subcategory> subcategories = [];
          if (selectedCategory?.id != null) {
            subcategories = await module.fetchSubcategories(ref, selectedCategory!.id!);
          }

          final items = subcategoryExpenses.map((subExpense) {
            final displayAmount = convertFromMga(subExpense.amount, rate);
            final subcategoryController = TextEditingController(text: subExpense.subcategory?.name ?? '');
            final amountController = TextEditingController(text: formatAmount(displayAmount));

            Subcategory? matched;
            if (subExpense.subcategory?.id != null && subcategories.isNotEmpty) {
              try {
                matched = subcategories.firstWhere((s) => s.id == subExpense.subcategory!.id);
              } catch (_) {}
            }
            matched ??= subExpense.subcategory;

            return {
              'subcategoryController': subcategoryController,
              'amountController': amountController,
              'subcategoryName': subExpense.subcategory?.name ?? '',
              'subcategoryId': subExpense.subcategory?.id,
              'subcategory': matched,
            };
          }).toList();

          return TransactionInitData(
            categories: filteredCategories,
            selectedCategory: selectedCategory,
            subcategories: subcategories,
            isMultipleAmounts: true,
            subcategoryAmounts: items,
          );
        }
      } catch (e) {
        debugPrint("❌ Error fetching subcategory expenses: $e");
      }
    }

    // Edit mode without subcategories: use total amount
    final amountText = formatAmount(convertFromMga(transaction.amount, rate));
    return TransactionInitData(
      categories: filteredCategories,
      selectedCategory: selectedCategory,
      amountText: amountText,
    );
  }
}
