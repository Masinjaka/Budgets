import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';

/// Get all budgets for the current user
Future<List<Budget>> getBudgets() {
  return Wrapper.execute(() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('budgets')
        .select('id, created_at, user_id, category, amount, amount_spent')
        .eq('user_id', userId);

    if (response.isEmpty) return [];

    return (response as List).map((item) => Budget.fromMap(item)).toList();
  });
}

/// Add a new budget
Future<void> addBudget(Budget budget) {
  return Wrapper.execute(() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await supabase.from('budgets').insert({
      'user_id': userId,
      'category': budget.category,
      'amount': budget.amount,
      'amount_spent': budget.amountSpent ?? '0',
    });
  });
}

/// Update an existing budget
Future<void> updateBudget(Budget budget) {
  return Wrapper.execute(() async {
    await supabase.from('budgets').update({
      'category': budget.category,
      'amount': budget.amount,
      'amount_spent': budget.amountSpent,
    }).eq('id', budget.id!);
  });
}

/// Delete a budget by ID
Future<void> deleteBudget(int id) {
  return Wrapper.execute(() async {
    await supabase.from('budgets').delete().eq('id', id);
  });
}
