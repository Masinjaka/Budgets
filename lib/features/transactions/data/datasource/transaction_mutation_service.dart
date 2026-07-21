import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/data/datasource/budget_spend_updater.dart';
import 'package:budgets/features/transactions/data/datasource/subcategory_writer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class TransactionMutationService {
  TransactionMutationService(this._client)
      : _budgetUpdater = BudgetSpendUpdater(_client),
        _subcategoryWriter = SubcategoryWriter(_client);

  final SupabaseClient _client;
  final BudgetSpendUpdater _budgetUpdater;
  final SubcategoryWriter _subcategoryWriter;

  Future<void> add({
    required String amount,
    required String description,
    required String categoryName,
    required Map<String, String>? subcategoryAmounts,
    required TransactionType type,
  }) async {
    final userId = _requireUserId();
    final categoryId = await _categoryId(categoryName, userId);
    final transactionId = const Uuid().v4();
    final numericAmount = _parseAmount(amount);
    final now = DateTime.now().toUtc().toIso8601String();

    await _client.from('transaction').insert({
      'id': transactionId,
      'user_id': userId,
      'description': description,
      'amount': numericAmount,
      'date': now,
      'category_id': categoryId,
      'transaction_type': type.value,
    });
    if (type == TransactionType.expense) {
      await _budgetUpdater.apply(
        categoryId: categoryId,
        userId: userId,
        delta: numericAmount,
      );
    }
    await _subcategoryWriter.replace(
      transactionId: transactionId,
      categoryId: categoryId,
      amounts: subcategoryAmounts,
    );
  }

  Future<void> delete(String transactionId) async {
    final userId = _requireUserId();
    final existing = await _client
        .from('transaction')
        .select('category_id, amount, transaction_type')
        .eq('id', transactionId)
        .eq('user_id', userId)
        .maybeSingle();
    if (existing == null) return;

    if (existing['transaction_type'] == TransactionType.expense.value &&
        existing['category_id'] != null) {
      await _budgetUpdater.apply(
        categoryId: existing['category_id'] as String,
        userId: userId,
        delta: -_asNum(existing['amount']),
      );
    }
    await _client
        .from('subcategory_expenses')
        .delete()
        .eq('transaction_id', transactionId);
    await _client.from('transaction').delete().eq('id', transactionId);
  }

  Future<void> edit({
    required String transactionId,
    required String amount,
    required String description,
    required String categoryName,
    required Map<String, String>? subcategoryAmounts,
    required TransactionType type,
    DateTime? date,
  }) async {
    final userId = _requireUserId();
    final categoryId = await _categoryId(categoryName, userId);
    final existing = await _client
        .from('transaction')
        .select('category_id, amount, transaction_type, date')
        .eq('id', transactionId)
        .eq('user_id', userId)
        .single();
    final numericAmount = _parseAmount(amount);

    await _client.from('transaction').update({
      'description': description,
      'amount': numericAmount,
      'date': date?.toUtc().toIso8601String() ?? existing['date'],
      'category_id': categoryId,
      'transaction_type': type.value,
    }).eq('id', transactionId);

    if (existing['transaction_type'] == TransactionType.expense.value &&
        existing['category_id'] != null) {
      await _budgetUpdater.apply(
        categoryId: existing['category_id'] as String,
        userId: userId,
        delta: -_asNum(existing['amount']),
      );
    }
    if (type == TransactionType.expense) {
      await _budgetUpdater.apply(
        categoryId: categoryId,
        userId: userId,
        delta: numericAmount,
      );
    }
    await _subcategoryWriter.replace(
      transactionId: transactionId,
      categoryId: categoryId,
      amounts: subcategoryAmounts,
    );
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('No authenticated user');
    return userId;
  }

  Future<String> _categoryId(String name, String userId) async {
    final row = await _client
        .from('categories')
        .select('id')
        .eq('name', name)
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) throw StateError('Category $name not found');
    return row['id'] as String;
  }

  int _parseAmount(String value) {
    final parsed = num.tryParse(value.replaceAll(RegExp(r'[,\s]'), ''));
    if (parsed == null) throw FormatException('Invalid amount');
    return parsed.round();
  }

  num _asNum(Object? value) =>
      value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
}
