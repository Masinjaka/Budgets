import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:budgets/features/receipts/data/services/receipt_query_service.dart';
import 'package:budgets/features/receipts/data/services/receipt_ai_service.dart';
import 'package:budgets/features/receipts/data/services/receipt_storage_service.dart';
import 'package:budgets/features/receipts/domain/models/receipt_scan.dart';
import 'package:budgets/features/receipts/domain/repositories/receipt_repository.dart';

class SupabaseReceiptRepository implements ReceiptRepository {
  const SupabaseReceiptRepository(
    this._storage,
    this._query,
    this._aiService,
  );

  final ReceiptStorageService _storage;
  final ReceiptQueryService _query;
  final ReceiptAiService _aiService;

  @override
  Future<AiEntryResult> process(
    ReceiptInputResult input, {
    required DateTime targetDate,
    required String outputLanguage,
  }) async {
    final scanId = await _storage.upload(input);
    return _aiService.process(
      scanId,
      targetDate: targetDate,
      outputLanguage: outputLanguage,
    );
  }

  @override
  Future<List<ReceiptScan>> scans() => _query.scans();

  @override
  Future<void> delete(String scanId) => _query.delete(scanId);
}
