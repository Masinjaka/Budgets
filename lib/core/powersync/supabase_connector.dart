import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Postgres Response codes that we cannot recover from by retrying.
final List<RegExp> _fatalResponseCodes = [
  // Class 22 — Data Exception (e.g. data type mismatch)
  RegExp(r'^22...$'),
  // Class 23 — Integrity Constraint Violation (e.g. NOT NULL, FK, UNIQUE)
  RegExp(r'^23...$'),
  // INSUFFICIENT PRIVILEGE — typically a row-level security violation
  RegExp(r'^42501$'),
];

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
          data[altKey] = op.id;
          if (op.op == UpdateType.put) {
            await table.upsert(data, onConflict: altKey);
          } else if (op.op == UpdateType.patch) {
            await table.update(op.opData!).eq(altKey, op.id);
          } else if (op.op == UpdateType.delete) {
            await table.delete().eq(altKey, op.id);
          }
        } else {
          // Standard table with `id` PK
          if (op.op == UpdateType.put) {
            final data = Map<String, dynamic>.of(op.opData!);
            data['id'] = op.id;
            await table.upsert(data);
          } else if (op.op == UpdateType.patch) {
            await table.update(op.opData!).eq('id', op.id);
          } else if (op.op == UpdateType.delete) {
            await table.delete().eq('id', op.id);
          }
        }
      }

      await transaction.complete();
    } on PostgrestException catch (e) {
      if (e.code != null &&
          _fatalResponseCodes.any((re) => re.hasMatch(e.code!))) {
        // Non-recoverable error — discard the transaction to avoid blocking
        debugPrint('PowerSync: fatal upload error, discarding $lastOp — $e');
        await transaction.complete();
      } else {
        // Retryable error (network, temporary server issue)
        rethrow;
      }
    }
  }
}
