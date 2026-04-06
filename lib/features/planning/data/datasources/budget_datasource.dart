import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Get all budgets for the current user
Future<List<Budget>> getBudgets() {
  return Wrapper.execute(() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final results = await powersync.db.getAll('''
      SELECT b.id, b.created_at, b.last_reset_at, b.user_id,
             b.amount, b.amount_spent, b.period,
             c.id AS cat_id, c.name AS cat_name, c.emoji AS cat_emoji,
             c.color AS cat_color, c.transaction_type AS cat_type
      FROM budgets b
      LEFT JOIN categories c ON b.category = c.id
      WHERE b.user_id = ?
      ORDER BY b.created_at ASC
    ''', [userId]);

    if (results.isEmpty) return [];

    return results.map((row) {
      return Budget(
        id: row['id'] is int ? row['id'] as int : int.tryParse(row['id'].toString()),
        createdAt: row['created_at'] != null
            ? DateTime.parse(row['created_at'] as String)
            : null,
        lastResetAt: row['last_reset_at'] != null
            ? DateTime.parse(row['last_reset_at'] as String)
            : null,
        userId: row['user_id'] as String?,
        category: row['cat_id'] != null
            ? Category(
                id: row['cat_id'] as String?,
                name: row['cat_name'] as String?,
                emoji: row['cat_emoji'] as String?,
                color: row['cat_color'] as String?,
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

    final budgetId = _uuid.v4();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    await powersync.db.execute(
      '''INSERT INTO budgets (id, user_id, category, amount, amount_spent, period, created_at, last_reset_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        budgetId,
        userId,
        budget.category?.id,
        budget.amount,
        budget.amountSpent ?? '0',
        budget.period ?? 'monthly',
        nowIso,
        nowIso,
      ],
    );
  });
}

/// Update an existing budget
Future<void> updateBudget(Budget budget) {
  return Wrapper.execute(() async {
    if (budget.id == null) throw Exception('Budget ID is required');

    await powersync.db.execute(
      '''UPDATE budgets
         SET category = ?, amount = ?, amount_spent = ?, period = ?
         WHERE id = ?''',
      [
        budget.category?.id,
        budget.amount,
        budget.amountSpent,
        budget.period ?? 'monthly',
        budget.id.toString(),
      ],
    );
  });
}

/// Delete a budget by ID
Future<void> deleteBudget(int id) {
  return Wrapper.execute(() async {
    await powersync.db.execute(
      'DELETE FROM budgets WHERE id = ?',
      [id.toString()],
    );
  });
}
