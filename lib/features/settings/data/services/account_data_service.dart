import 'package:budgets/core/offline/legacy_image_data_cleanup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountDataService {
  const AccountDataService(this._client);

  final SupabaseClient _client;

  String get accountConfirmation => _client.auth.currentUser?.email ?? '';

  Future<void> deleteAllData(String confirmation) =>
      _invoke(action: 'data', confirmation: confirmation);

  Future<void> deleteAccount(String confirmation) async {
    await _invoke(action: 'account', confirmation: confirmation);
    await _client.auth.signOut(scope: SignOutScope.local);
  }

  Future<void> _invoke({
    required String action,
    required String confirmation,
  }) async {
    if (_client.auth.currentSession == null) {
      throw StateError('No authenticated session');
    }
    await deleteLegacyImageData();
    try {
      await _client.functions.invoke(
        'delete-user-data',
        body: {'action': action, 'confirmation': confirmation},
      );
    } on FunctionException catch (error) {
      throw Exception(_messageFrom(error.details));
    }
  }

  String _messageFrom(Object? details) {
    if (details is! Map) return 'Deletion failed';
    final error = details['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    return 'Deletion failed';
  }
}
