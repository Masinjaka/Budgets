import 'package:budgets/features/transactions/domain/providers/paginated_expenses_provider.dart';
import 'package:budgets/features/transactions/domain/providers/paginated_incomes_provider.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/features/categories/domain/providers/filter_provider.dart';
import 'package:budgets/features/categories/domain/providers/subcategories_provider.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/transactions/presentation/modules/subcategory_amount_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';

class TransactionSubmissionResult {
  final bool success;
  final String message;
  final double? totalAmount;

  TransactionSubmissionResult({
    required this.success,
    required this.message,
    this.totalAmount,
  });
}

class TransactionModule {
  final _subcategoryManager = SubcategoryAmountManager();

  DateTime? getUserCreationDate() {
    final user = supabase.auth.currentUser;
    return user != null ? DateTime.parse(user.createdAt) : null;
  }

  bool filterTransaction(WidgetRef ref, List<String> selectedCategories,
      String fromDate, String toDate, BuildContext context) {
    if (fromDate.isNotEmpty && toDate.isNotEmpty) {
      final start = DateTime.parse(fromDate);
      final end = DateTime.parse(toDate);
      if (end.isBefore(start)) {
        showInfoToast(context,
            'La date de fin ne doit pas être antérieure à la date de début');
        return false;
      }
      ref
          .read(dateRangeProvider.notifier)
          .update(DateTimeRange(start: start, end: end));
    }
    ref.read(selectedCategoriesProvider.notifier).update(selectedCategories);
    return true;
  }

  Future<List<Category>> fetchCategories(WidgetRef ref) =>
      ref.read(categoriesProvider.future);

  Future<List<Subcategory>> fetchSubcategories(
          WidgetRef ref, String categoryId) =>
      ref.read(subcategoriesProvider(categoryId).future);

  // Delegate to SubcategoryAmountManager
  Map<String, dynamic> createSubcategoryAmountItem() =>
      _subcategoryManager.createItem();
  bool validateSubcategoryAmounts(List<Map<String, dynamic>> items) =>
      _subcategoryManager.validate(items);
  Map<String, String> buildSubcategoryAmountsMap(
          List<Map<String, dynamic>> items) =>
      _subcategoryManager.buildAmountsMap(items);
  double calculateTotalAmount(List<Map<String, dynamic>> items) =>
      _subcategoryManager.calculateTotal(items);

  void addSubcategoryAmount(
          {required List<Map<String, dynamic>> subcategoryAmounts,
          required GlobalKey<AnimatedListState> listKey,
          required VoidCallback onStateChanged}) =>
      _subcategoryManager.add(
          items: subcategoryAmounts,
          listKey: listKey,
          onStateChanged: onStateChanged);

  void removeSubcategoryAmount(
          {required int index,
          required List<Map<String, dynamic>> subcategoryAmounts,
          required GlobalKey<AnimatedListState> listKey,
          required Widget Function(Map<String, dynamic>, int, Animation<double>)
              buildRemovedItem,
          required VoidCallback onStateChanged}) =>
      _subcategoryManager.remove(
          index: index,
          items: subcategoryAmounts,
          listKey: listKey,
          buildRemoved: buildRemovedItem,
          onStateChanged: onStateChanged);

  void clearAllSubcategoryAmounts(
          {required List<Map<String, dynamic>> subcategoryAmounts,
          required GlobalKey<AnimatedListState> listKey,
          required Widget Function(Map<String, dynamic>, int, Animation<double>)
              buildRemovedItem,
          required VoidCallback onStateChanged}) =>
      _subcategoryManager.clearAll(
          items: subcategoryAmounts,
          listKey: listKey,
          buildRemoved: buildRemovedItem,
          onStateChanged: onStateChanged);

  Future<bool> addTransaction(
      {String? amount,
      String? description,
      String? categoryName,
      Map<String, String>? subcategoryAmounts,
      TransactionType? transactionType,
      required GlobalKey<FormState> formKey,
      required WidgetRef ref}) async {
    if (!formKey.currentState!.validate()) return false;
    try {
      await ref.read(transactionsProvider.notifier).addUserTransaction(amount,
          description, categoryName, subcategoryAmounts, transactionType);
      if (transactionType == TransactionType.income) {
        ref.read(paginatedIncomesProvider.notifier).refresh();
      } else {
        ref.read(paginatedExpensesProvider.notifier).refresh();
      }
      return true;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  Future<bool> editTransaction(
      {required String transactionId,
      String? amount,
      String? description,
      String? categoryName,
      Map<String, String>? subcategoryAmounts,
      TransactionType? transactionType,
      DateTime? date,
      required GlobalKey<FormState> formKey,
      required WidgetRef ref,
      TransactionModel? originalTransaction}) async {
    if (!formKey.currentState!.validate()) return false;
    try {
      await ref.read(transactionsProvider.notifier).editTransaction(
          transactionId,
          amount,
          description,
          categoryName,
          subcategoryAmounts,
          transactionType,
          date,
          originalTransaction: originalTransaction);
      return true;
    } catch (e) {
      debugPrint('Error editing transaction: $e');
      return false;
    }
  }

  Future<TransactionSubmissionResult> submitTransaction({
    required GlobalKey<FormState> formKey,
    required Category? selectedCategory,
    required bool isMultipleAmounts,
    required List<Map<String, dynamic>> subcategoryAmounts,
    required TextEditingController montantController,
    required TextEditingController descriptionController,
    required TransactionType transactionType,
    required WidgetRef ref,
    String? transactionId,
    DateTime? transactionDate,
    TransactionModel? originalTransaction,
  }) async {
    if (!formKey.currentState!.validate()) {
      return TransactionSubmissionResult(
          success: false, message: 'Validation du formulaire échouée');
    }
    if (selectedCategory == null) {
      return TransactionSubmissionResult(
          success: false, message: 'Tu dois choisir une catégorie');
    }

    final currencyState = await ref.read(currencyControllerProvider.future);
    final rate = currencyState.rateFor(currencyState.code);
    String toMgaString(String raw) =>
        convertToMga(parseAmountInput(raw), rate).round().toString();
    final description = descriptionController.text.trim().isEmpty
        ? ""
        : descriptionController.text.trim();

    if (isMultipleAmounts) {
      if (!validateSubcategoryAmounts(subcategoryAmounts)) {
        return TransactionSubmissionResult(
            success: false,
            message: 'Veuillez remplir toutes les sous-catégories et montants');
      }
      final displayMap = buildSubcategoryAmountsMap(subcategoryAmounts);
      final totalDisplay = calculateTotalAmount(subcategoryAmounts);
      final totalMga = convertToMga(totalDisplay, rate).round();
      final mgaMap = displayMap.map((k, v) => MapEntry(k, toMgaString(v)));

      final ok = transactionId != null
          ? await editTransaction(
              transactionId: transactionId,
              amount: totalMga.toString(),
              description: description,
              categoryName: selectedCategory.name ?? '',
              subcategoryAmounts: mgaMap,
              transactionType: transactionType,
              date: transactionDate,
              formKey: formKey,
              ref: ref,
              originalTransaction: originalTransaction)
          : await addTransaction(
              amount: totalMga.toString(),
              description: description,
              categoryName: selectedCategory.name ?? '',
              subcategoryAmounts: mgaMap,
              transactionType: transactionType,
              formKey: formKey,
              ref: ref);

      return TransactionSubmissionResult(
        success: ok,
        message: ok
            ? (transactionId != null
                ? '${transactionType.displayName} modifiée avec succès'
                : '${transactionType.displayName} avec sous-catégories ajoutée: ${totalDisplay.toStringAsFixed(2)}')
            : (transactionId != null
                ? 'Erreur lors de la modification de la transaction.'
                : 'Erreur lors de l\'ajout de la transaction.'),
        totalAmount: ok ? totalDisplay : null,
      );
    } else {
      final ok = transactionId != null
          ? await editTransaction(
              transactionId: transactionId,
              amount: toMgaString(montantController.text.trim()),
              description: description,
              categoryName: selectedCategory.name ?? '',
              transactionType: transactionType,
              date: transactionDate,
              formKey: formKey,
              ref: ref,
              originalTransaction: originalTransaction)
          : await addTransaction(
              amount: toMgaString(montantController.text.trim()),
              description: description,
              categoryName: selectedCategory.name ?? '',
              transactionType: transactionType,
              formKey: formKey,
              ref: ref);

      return TransactionSubmissionResult(
        success: ok,
        message: ok
            ? (transactionId != null
                ? '${transactionType.displayName} modifiée avec succès'
                : '${transactionType.displayName} ajoutée: ${montantController.text.trim()}')
            : (transactionId != null
                ? 'Erreur lors de la modification de la transaction.'
                : 'Erreur lors de l\'ajout de la transaction.'),
      );
    }
  }
}
