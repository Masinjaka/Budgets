import 'package:budgets/features/ai_entry/data/services/ai_function_error_mapper.dart';
import 'package:budgets/core/monitoring/development_log.dart';
import 'package:budgets/features/ai_entry/domain/errors/ai_entry_exception.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptAiService {
  const ReceiptAiService(this._client);

  final SupabaseClient _client;

  Future<AiEntryResult> process(
    String receiptId, {
    required DateTime targetDate,
    required String outputLanguage,
  }) async {
    if (_client.auth.currentSession == null) {
      throw const AiEntryException(
        code: 'unauthorized',
        message: 'Please sign in to scan receipts.',
        status: 401,
      );
    }
    try {
      final response = await _client.functions.invoke(
        'process-finance-message',
        body: {
          'receipt_id': receiptId,
          'output_language': outputLanguage,
          'timezone': DateTime.now().timeZoneName,
          'target_date': _dateKey(targetDate),
          'timezone_offset_minutes': targetDate.timeZoneOffset.inMinutes,
        },
      );
      final data = response.data;
      return AiEntryResult.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : const {},
      );
    } on FunctionException catch (error, stackTrace) {
      DevelopmentLog.error('process receipt', error, stackTrace);
      throw AiFunctionErrorMapper.map(error);
    }
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
