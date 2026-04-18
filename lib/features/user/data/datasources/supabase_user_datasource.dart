import 'dart:async';

import 'package:budgets/core/powersync/powersync.dart' as powersync_runtime;
import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:budgets/features/user/domain/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserDataSource {
  SupabaseUserDataSource(this._client);
  final SupabaseClient _client;

  Future<UserModel> getCurrentUserRow() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');

    var results = await _fetchUserRows(uid);

    if (results.isEmpty) {
      debugPrint(
        'User row missing locally for $uid. Waiting for PowerSync sync before '
        'falling back to auth metadata.',
      );
      await powersync_runtime.connectPowerSyncForCurrentUser(waitForSync: true);
      results = await _waitForUserRows(uid);
    }

    if (results.isEmpty) {
      final fallback = _buildFallbackUserModel();
      if (fallback != null) {
        return fallback;
      }
      throw StateError('User row not found');
    }

    return UserModel.fromJson(results.first);
  }

  Stream<UserModel?> watchCurrentUserRow() async* {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');

    await powersync_runtime.connectPowerSyncForCurrentUser(waitForSync: true);

    await for (final rows in _watchUserRows(uid)) {
      if (rows.isEmpty) continue;
      yield UserModel.fromJson(rows.first);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserRows(String uid) {
    return powersync.db.getAll('''
      SELECT username, profile_photo, currency_code
      FROM user
      WHERE user_id = ?
      LIMIT 1
    ''', [uid]);
  }

  Future<List<Map<String, dynamic>>> _waitForUserRows(String uid) {
    return _watchUserRows(uid)
        .firstWhere((rows) => rows.isNotEmpty)
        .timeout(const Duration(seconds: 10), onTimeout: () => const []);
  }

  Stream<List<Map<String, dynamic>>> _watchUserRows(String uid) {
    return powersync.db.watch(
      '''
          SELECT username, profile_photo, currency_code
          FROM user
          WHERE user_id = ?
          LIMIT 1
          ''',
      parameters: [uid],
      triggerOnTables: const ['user'],
    ).map((rows) => [
          for (final row in rows) Map<String, dynamic>.from(row),
        ]);
  }

  UserModel? _buildFallbackUserModel() {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

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
