import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:budgets/features/receipts/domain/models/receipt_scan.dart';

abstract interface class ReceiptRepository {
  Future<AiEntryResult> process(
    ReceiptInputResult input, {
    required DateTime targetDate,
    required String outputLanguage,
  });

  Future<List<ReceiptScan>> scans();

  Future<void> delete(String scanId);
}
