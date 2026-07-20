import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Get all budgets for the current user
Future<List<Budget>> getBudgets() {
  return Wrapper.execute(() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final results = await Supabase.instance.client
        .from('budgets')
        .select(
          'id, created_at, last_reset_at, user_id, amount, amount_spent, '
          'period, category_data:categories!budgets_category_fkey'
          '(id, name, emoji, color)',
        )
        .eq('user_id', userId)
        .order('created_at');

    if (results.isEmpty) return [];

    return results.map((row) {
      final category = row['category_data'] as Map<String, dynamic>?;
      return Budget(
        id: row['id']?.toString(),
        createdAt: row['created_at'] != null
            ? DateTime.parse(row['created_at'] as String)
            : null,
        lastResetAt: row['last_reset_at'] != null
            ? DateTime.parse(row['last_reset_at'] as String)
            : null,
        userId: row['user_id'] as String?,
        category: category != null
            ? Category(
                id: category['id'] as String?,
                name: category['name'] as String?,
                emoji: category['emoji'] as String?,
                color: category['color'] as String?,
              )
            : null,
        amount: row['amount'] as String?,
        amountSpent: row['amount_spent'] as String?,
        period: row['period'] as String?,
      );
    }).toList();
  });
}

/// Add a new budget
Future<void> addBudget(Budget budget) {
  return Wrapper.execute(() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final now = DateTime.now().toUtc().toIso8601String();
    await Supabase.instance.client.from('budgets').insert({
      'user_id': userId,
      'category': budget.category?.id,
      'amount': budget.amount,
      'amount_spent': budget.amountSpent ?? '0',
      'period': budget.period ?? 'monthly',
      'created_at': now,
      'last_reset_at': now,
    });
  });
}

/// Update an existing budget
Future<void> updateBudget(Budget budget) {
  return Wrapper.execute(() async {
    if (budget.id == null) throw Exception('Budget ID is required');

    await Supabase.instance.client.from('budgets').update({
      'category': budget.category?.id,
      'amount': budget.amount,
      'amount_spent': budget.amountSpent,
      'period': budget.period ?? 'monthly',
    }).eq('id', budget.id!);
  });
}

/// Delete a budget by ID
Future<void> deleteBudget(String id) {
  return Wrapper.execute(() async {
    await Supabase.instance.client.from('budgets').delete().eq('id', id);
  });
}
