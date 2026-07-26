import 'package:budgets/features/user/domain/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserDataSource {
  SupabaseUserDataSource(this._client);
  final SupabaseClient _client;

  Future<UserModel> getCurrentUserRow() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');

    final row = await _client
        .from('user')
        .select('username, profile_photo, currency_code')
        .eq('user_id', uid)
        .maybeSingle();
    return row == null ? _buildFallbackUserModel() : UserModel.fromJson(row);
  }

  UserModel _buildFallbackUserModel() {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw StateError('No authenticated user');

    final metadata = authUser.userMetadata ?? const <String, dynamic>{};
    final email = authUser.email;
    final fallbackName =
        (metadata['username'] as String?)?.trim().isNotEmpty == true
            ? metadata['username'] as String
            : _emailPrefix(email);

    return UserModel(
      name: fallbackName?.isNotEmpty == true ? fallbackName : 'Utilisateur',
      profilePhoto: metadata['profile_photo'] as String?,
      currencyCode: metadata['currency_code'] as String?,
    );
  }

  String? _emailPrefix(String? email) {
    if (email == null || email.isEmpty) return null;
    return email.split('@').first.trim();
  }

  Future<void> updateUsername(String username) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');

    await _client.from('user').upsert(
      {'user_id': uid, 'username': username},
      onConflict: 'user_id',
    );
  }

  Future<void> updateCurrencyCode(String currencyCode) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');

    await _client.from('user').upsert(
      {'user_id': uid, 'currency_code': currencyCode},
      onConflict: 'user_id',
    );
  }
}
