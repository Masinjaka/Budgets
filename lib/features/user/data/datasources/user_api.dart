import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/features/user/domain/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<UserModel> getUser() {
  return Wrapper.execute(() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');

    final results = await powersync.db.getAll('''
      SELECT username, profile_photo, currency_code
      FROM user
      WHERE user_id = ?
      LIMIT 1
    ''', [uid]);

    if (results.isEmpty) {
      throw Exception('User not found in local database');
    }

    final row = results.first;
    debugPrint('User response (PowerSync): $row');

    return UserModel.fromJson(row);
  });
}
