import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budgets/features/home/domain/errors/wallet_selection_required_exception.dart';

class EnvelopeService {
  const EnvelopeService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> envelopes(DateTime month) async {
    final rows = await _client
        .from('envelopes')
        .select(
          'id,name,category_id,amount,remaining_amount,currency_code,'
          'categories(name,emoji,color)',
        )
        .eq('period_month', _monthKey(month))
        .order('created_at');
    return rows.map(Map<String, dynamic>.from).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> expenseCategories() async {
    final rows = await _client
        .from('categories')
        .select('id,name,emoji,color')
        .eq('transaction_type', 'expense')
        .order('name');
    return rows.map(Map<String, dynamic>.from).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> wallets() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Please sign in to view wallets.');
    final rows = await _client
        .from('wallets')
        .select('id,name,balance,currency_code,icon_key,is_default')
        .eq('user_id', userId)
        .order('created_at');
    return rows.map(Map<String, dynamic>.from).toList(growable: false);
  }

  Future<void> addEnvelope({
    required String name,
    required String categoryId,
    required int amount,
    required DateTime month,
    String? walletId,
  }) async {
    try {
      await _client.rpc('fund_envelope', params: {
        'p_name': name,
        'p_category_id': categoryId,
        'p_amount': amount,
        'p_period_month': _monthKey(month),
        'p_wallet_id': walletId,
      });
    } on PostgrestException catch (error) {
      const marker = 'wallet_selection_required:';
      if (error.message.contains(marker)) {
        final value = error.message.split(marker)[1].split(' ').first;
        throw WalletSelectionRequiredException(
          requiredAmount: int.tryParse(value) ?? amount,
        );
      }
      rethrow;
    }
  }

  Future<void> deleteEnvelope(String id) =>
      _client.rpc('delete_funded_envelope', params: {'p_envelope_id': id});

  String _monthKey(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
}
