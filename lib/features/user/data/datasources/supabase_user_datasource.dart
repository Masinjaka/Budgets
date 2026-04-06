import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/features/user/domain/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserDataSource {
  SupabaseUserDataSource(this._client);
  final SupabaseClient _client;

  Future<UserModel> getCurrentUserRow() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');

    final results = await powersync.db.getAll('''
      SELECT username, profile_photo, currency_code
      FROM user
      WHERE user_id = ?
      LIMIT 1
    ''', [uid]);

    if (results.isEmpty) throw StateError('User row not found');

    return UserModel.fromJson(results.first);
  }

  Future<void> updateUsername(String username) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');

    await powersync.db.execute(
      'UPDATE user SET username = ? WHERE user_id = ?',
      [username, uid],
    );
  }

  Future<void> updateCurrencyCode(String currencyCode) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');

    await powersync.db.execute(
      'UPDATE user SET currency_code = ? WHERE user_id = ?',
      [currencyCode, uid],
    );
  }
}
