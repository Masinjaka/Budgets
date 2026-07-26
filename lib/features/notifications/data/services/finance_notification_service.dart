import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceNotificationService {
  const FinanceNotificationService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> notifications() async {
    final rows = await _client
        .from('finance_notifications')
        .select(
          'id,envelope_id,envelope_name,amount,period_month,is_read,created_at',
        )
        .order('created_at', ascending: false);
    return rows.map(Map<String, dynamic>.from).toList(growable: false);
  }

  Future<void> markRead(String id) async {
    await _client
        .from('finance_notifications')
        .update({'is_read': true}).eq('id', id);
  }
}
