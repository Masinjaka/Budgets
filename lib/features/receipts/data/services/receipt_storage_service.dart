import 'dart:io';

import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ReceiptStorageService {
  const ReceiptStorageService(this._client);

  static const _bucket = 'receipts';
  static const _maxFileBytes = 15 * 1024 * 1024;
  final SupabaseClient _client;

  Future<String> upload(ReceiptInputResult input) async {
    final userId = _requireUserId();
    final scanId = const Uuid().v4();
    final paths = <String>[];
    final mimeTypes = <String>[];
    try {
      for (var index = 0; index < input.paths.length; index++) {
        final file = File(input.paths[index]);
        final size = await file.length();
        if (size > _maxFileBytes) {
          throw StateError('Each receipt file must be smaller than 15 MB.');
        }
        final type = _mimeType(file.path);
        final extension = _extensionFor(type);
        final path = '$userId/$scanId/page-${index + 1}.$extension';
        await _client.storage.from(_bucket).upload(
              path,
              file,
              fileOptions: FileOptions(contentType: type),
            );
        paths.add(path);
        mimeTypes.add(type);
      }
      await _client.from('receipt_scans').insert({
        'id': scanId,
        'user_id': userId,
        'storage_paths': paths,
        'mime_types': mimeTypes,
        'source': input.source == ReceiptInputSource.scannedReceipt
            ? 'camera'
            : 'file',
      });
      return scanId;
    } catch (_) {
      if (paths.isNotEmpty) {
        await _client.storage.from(_bucket).remove(paths);
      }
      rethrow;
    }
  }

  Future<void> deletePaths(List<String> paths) async {
    if (paths.isEmpty) return;
    await _client.storage.from(_bucket).remove(paths);
  }

  String _requireUserId() {
    final id = _client.auth.currentUser?.id;
    if (id != null) return id;
    throw StateError('Please sign in to scan receipts.');
  }

  String _mimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    throw StateError('Only JPG, PNG, and PDF receipts are supported.');
  }

  String _extensionFor(String type) => switch (type) {
        'application/pdf' => 'pdf',
        'image/png' => 'png',
        _ => 'jpg',
      };
}
