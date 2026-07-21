import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetSpendUpdater {
  const BudgetSpendUpdater(this._client);

  final SupabaseClient _client;

  Future<void> apply({
    required String categoryId,
    required String userId,
    required num delta,
  }) async {
    final rows = await _client
        .from('budgets')
        .select('id, amount_spent')
        .eq('category', categoryId)
        .eq('user_id', userId);
    for (final row in rows) {
      final current = num.tryParse(row['amount_spent']?.toString() ?? '') ?? 0;
      final next = (current + delta).clamp(0, double.infinity);
      await _client
          .from('budgets')
          .update({'amount_spent': next.toString()}).eq('id', row['id'] as int);
    }
  }
}
