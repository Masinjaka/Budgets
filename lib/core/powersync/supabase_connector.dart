import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tables whose Supabase primary key is NOT the PowerSync-generated `id`.
/// Maps table name → the column that acts as the real primary key.
const _nonIdPrimaryKeys = <String, String>{
  'notification_settings': 'user_id',
};

/// Connector that uses Supabase for authentication and data upload.
class SupabaseConnector extends PowerSyncBackendConnector {
  final String powersyncUrl;
  Future<void>? _refreshFuture;

  SupabaseConnector({required this.powersyncUrl});

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // Wait for any pending session refresh
    await _refreshFuture;

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    final token = session.accessToken;
    final userId = session.user.id;
    final expiresAt = session.expiresAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);

    return PowerSyncCredentials(
      endpoint: powersyncUrl,
      token: token,
      userId: userId,
      expiresAt: expiresAt,
    );
  }

  @override
  void invalidateCredentials() {
    // Trigger a session refresh if auth fails on PowerSync.
    // Timeout to avoid waiting for long retries; ignore errors.
    _refreshFuture = Supabase.instance.client.auth
        .refreshSession()
        .timeout(const Duration(seconds: 5))
        .then((_) => null, onError: (_) => null);
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    final rest = Supabase.instance.client.rest;
    CrudEntry? lastOp;

    try {
      for (var op in transaction.crud) {
        lastOp = op;

        final table = rest.from(op.table);
        final altKey = _nonIdPrimaryKeys[op.table];

        if (altKey != null) {
          // Table whose Supabase PK is NOT `id` (e.g. notification_settings)
          // PowerSync's op.id holds the real PK value (user_id).
          final data = Map<String, dynamic>.of(op.opData!);
          _normalizeOpDataForSupabase(op.table, data);
          data[altKey] = op.id;
          if (op.op == UpdateType.put) {
            await table.upsert(data, onConflict: altKey);
          } else if (op.op == UpdateType.patch) {
            await table.update(data).eq(altKey, op.id);
          } else if (op.op == UpdateType.delete) {
            await table.delete().eq(altKey, op.id);
          }
        } else {
          // Standard table with `id` PK
          if (op.op == UpdateType.put) {
            final data = Map<String, dynamic>.of(op.opData!);
            _normalizeOpDataForSupabase(op.table, data);
            data['id'] = op.id;
            if (op.table == 'device_tokens') {
              await table.upsert(data, onConflict: 'user_id,token');
            } else {
              await table.upsert(data);
            }
          } else if (op.op == UpdateType.patch) {
            final data = Map<String, dynamic>.of(op.opData!);
            _normalizeOpDataForSupabase(op.table, data);
            await table.update(data).eq('id', op.id);
          } else if (op.op == UpdateType.delete) {
            await table.delete().eq('id', op.id);
          }
        }
      }

      await transaction.complete();
    } on PostgrestException catch (e) {
      // Never mark a failed upload transaction as complete. Completing here
      // acknowledges local CRUD that may not exist on the server, and the next
      // sync checkpoint can then remove those local rows from the app.
      debugPrint('PowerSync: upload failed, will retry $lastOp — $e');
      rethrow;
    }
  }

  void _normalizeOpDataForSupabase(String table, Map<String, dynamic> data) {
    // Postgres `transaction.amount` is bigint; PowerSync can carry "45568.0"
    // strings from local writes, so coerce safely before upload.
    if (table == 'transaction' && data.containsKey('amount')) {
      final normalized = _toBigintSafeInt(data['amount']);
      if (normalized != null) {
        data['amount'] = normalized;
      }
    }
  }

  int? _toBigintSafeInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    final cleaned = value.toString().replaceAll(RegExp(r'[,\s]'), '');
    final parsed = num.tryParse(cleaned);
    if (parsed == null) return null;
    return parsed.round();
  }
}
