import 'package:budgets/features/user/domain/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserDataSource {
  SupabaseUserDataSource(this._client);
  final SupabaseClient _client;

  Future<UserModel> getCurrentUserRow() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');
    // Assuming table name is 'user'
    final data = await _client
        .from('user')
        .select('username, profile_photo, currency_code')
        .eq('user_id', uid)
        .single();

    return UserModel.fromJson(data);
  }

  Future<void> updateUsername(String username) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');
    await _client
        .from('user')
        .update({'username': username}).eq('user_id', uid);
  }

  Future<void> updateCurrencyCode(String currencyCode) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');
    await _client
        .from('user')
        .update({'currency_code': currencyCode}).eq('user_id', uid);
  }
}
