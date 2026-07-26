import 'package:budgets/features/receipts/domain/models/receipt_scan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptQueryService {
  const ReceiptQueryService(this._client);

  static const _bucket = 'receipts';
  final SupabaseClient _client;

  Future<List<ReceiptScan>> scans() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Please sign in to view receipts.');
    final rows = await _client
        .from('receipt_scans')
        .select(
          'id,storage_paths,mime_types,status,error_message,created_at',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return Future.wait(rows.map(_scanFromJson));
  }

  Future<void> delete(String scanId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Please sign in to delete receipts.');
    final row = await _client
        .from('receipt_scans')
        .select('storage_paths')
        .eq('id', scanId)
        .eq('user_id', userId)
        .single();
    final paths = _strings(row['storage_paths']);
    await _client.storage.from(_bucket).remove(paths);
    await _client
        .from('receipt_scans')
        .delete()
        .eq('id', scanId)
        .eq('user_id', userId);
  }

  Future<ReceiptScan> _scanFromJson(Map<String, dynamic> json) async {
    final paths = _strings(json['storage_paths']);
    final urls = await Future.wait(
      paths.map(
          (path) => _client.storage.from(_bucket).createSignedUrl(path, 3600)),
    );
    return ReceiptScan(
      id: json['id'] as String,
      storagePaths: paths,
      mimeTypes: _strings(json['mime_types']),
      signedUrls: urls,
      status: json['status'] as String? ?? 'uploaded',
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  List<String> _strings(Object? value) =>
      (value as List? ?? const []).whereType<String>().toList(growable: false);
}
