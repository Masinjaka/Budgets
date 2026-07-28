import 'package:budgets/features/home/domain/errors/wallet_deletion_exception.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletService {
  const WalletService(this._client);

  final SupabaseClient _client;

  Future<List<WalletSummary>> wallets() async {
    final rows = await _client
        .from('wallets')
        .select(_selection)
        .eq('user_id', _requireUserId())
        .order('created_at');
    return rows.map(_wallet).toList(growable: false);
  }

  Future<WalletSummary> add(AddWalletInput input) async {
    final row = await _client
        .from('wallets')
        .insert({
          'user_id': _requireUserId(),
          'name': input.name,
          'balance': input.initialBalance,
        })
        .select(_selection)
        .single();
    return _wallet(row);
  }

  Future<WalletSummary> update(
    String walletId,
    AddWalletInput input,
  ) async {
    final row = await _client
        .from('wallets')
        .update({
          'name': input.name,
          'balance': input.initialBalance,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', walletId)
        .eq('user_id', _requireUserId())
        .select(_selection)
        .single();
    return _wallet(row);
  }

  Future<void> delete(String walletId) async {
    try {
      await _client
          .from('wallets')
          .delete()
          .eq('id', walletId)
          .eq('user_id', _requireUserId())
          .eq('is_default', false);
    } on PostgrestException catch (error) {
      if (error.code == '23503') {
        throw const WalletDeletionException.inUse();
      }
      rethrow;
    }
  }

  Future<int> totalFunds() async {
    final rows = await _client
        .from('wallets')
        .select('balance')
        .eq('user_id', _requireUserId());
    return rows.fold<int>(
      0,
      (sum, row) => sum + (row['balance'] as num? ?? 0).round(),
    );
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId != null) return userId;
    throw const AuthException('Please sign in to manage wallets.');
  }

  WalletSummary _wallet(Map<String, dynamic> row) =>
      WalletSummary.fromJson(Map<String, dynamic>.from(row));

  static const _selection = 'id,name,balance,currency_code,icon_key,is_default';
}
