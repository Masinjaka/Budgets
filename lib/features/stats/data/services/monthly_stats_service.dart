import 'package:supabase_flutter/supabase_flutter.dart';

class MonthlyStatsService {
  const MonthlyStatsService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> transactionsForMonth(
    DateTime month,
  ) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final rows = await _client
        .from('transaction')
        .select(
          'amount,date,transaction_type,currency_code,'
          'categories(name,emoji)',
        )
        .gte('date', start.toUtc().toIso8601String())
        .lt('date', end.toUtc().toIso8601String())
        .order('date');
    return rows.map(Map<String, dynamic>.from).toList(growable: false);
  }
}
