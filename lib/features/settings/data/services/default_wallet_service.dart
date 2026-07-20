import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DefaultWalletService {
  const DefaultWalletService(this._client);

  final SupabaseClient _client;

  Future<List<WalletSummary>> wallets() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Please sign in to view wallets.');
    final rows = await _client
        .from('wallets')
        .select('id,name,balance,currency_code,icon_key,is_default')
        .eq('user_id', userId)
        .order('created_at');
    return rows
        .map((row) => WalletSummary.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<void> setDefault(String walletId) =>
      _client.rpc('set_default_wallet', params: {'p_wallet_id': walletId});
}
