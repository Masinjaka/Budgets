import 'package:budgets/features/ai_entry/data/services/ai_function_error_mapper.dart';
import 'package:budgets/core/monitoring/development_log.dart';
import 'package:budgets/features/ai_entry/domain/errors/ai_entry_exception.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_quota.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/ai_entry/data/services/finance_entry_query_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiEntryService {
  const AiEntryService(this._client);

  static const dailyRequestLimit = 20;
  final SupabaseClient _client;

  Future<AiQuota> aiQuota() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AiEntryException(
        code: 'unauthorized',
        message: 'Please sign in to view your AI usage.',
        status: 401,
      );
    }
    final response = await _client.rpc(
      'get_my_ai_quota',
      params: {'p_daily_limit': dailyRequestLimit},
    );
    return AiQuota.fromJson(_record(response));
  }

  Future<AiEntryResult> processMessage(
    String message, {
    required DateTime targetDate,
  }) async {
    if (_client.auth.currentSession == null) {
      throw const AiEntryException(
        code: 'unauthorized',
        message: 'Please sign in to add entries.',
        status: 401,
      );
    }
    try {
      final response = await _client.functions.invoke(
        'process-finance-message',
        body: {
          'message': message,
          'timezone': DateTime.now().timeZoneName,
          'target_date': _dateKey(targetDate),
          'timezone_offset_minutes': targetDate.timeZoneOffset.inMinutes,
        },
      );
      return AiEntryResult.fromJson(_record(response.data));
    } on FunctionException catch (error, stackTrace) {
      DevelopmentLog.error('process finance message', error, stackTrace);
      throw AiFunctionErrorMapper.map(error);
    }
  }

  Future<AiEntryResult> resumeMessage({
    required String requestId,
    required Map<String, dynamic> extraction,
    String? walletId,
    required bool useAllWallets,
    required DateTime targetDate,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'process-finance-message',
        body: {
          'resume_request_id': requestId,
          'extraction': extraction,
          'expense_wallet_id': walletId,
          'use_all_wallets': useAllWallets,
          'target_date': _dateKey(targetDate),
        },
      );
      return AiEntryResult.fromJson(_record(response.data));
    } on FunctionException catch (error, stackTrace) {
      DevelopmentLog.error('resume finance message', error, stackTrace);
      throw AiFunctionErrorMapper.map(error);
    }
  }

  Future<void> cancelPendingRequest(String requestId) async {
    try {
      await _client.functions.invoke(
        'process-finance-message',
        body: {'cancel_request_id': requestId},
      );
    } on FunctionException catch (error, stackTrace) {
      DevelopmentLog.error('cancel finance message', error, stackTrace);
      throw AiFunctionErrorMapper.map(error);
    }
  }

  Future<List<FinanceEntry>> entriesForDate(DateTime date) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AiEntryException(
        code: 'unauthorized',
        message: 'Please sign in to view entries.',
        status: 401,
      );
    }
    return FinanceEntryQueryService(_client).entriesForDate(userId, date);
  }

  Future<Set<DateTime>> activityDatesForMonth(DateTime month) {
    return FinanceEntryQueryService(
      _client,
    ).activityDatesForMonth(_requireUserId(), month);
  }

  Future<List<WalletSummary>> wallets() async {
    final userId = _requireUserId();
    final rows = await _client
        .from('wallets')
        .select('id,name,balance,currency_code,icon_key,is_default')
        .eq('user_id', userId)
        .order('created_at');
    return rows
        .map((row) => WalletSummary.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<WalletSummary> addWallet(AddWalletInput input) async {
    final row = await _client
        .from('wallets')
        .insert({
          'user_id': _requireUserId(),
          'name': input.name,
          'balance': input.initialBalance,
        })
        .select('id,name,balance,currency_code,icon_key,is_default')
        .single();
    return WalletSummary.fromJson(Map<String, dynamic>.from(row));
  }

  Future<int> totalFunds() async {
    final userId = _requireUserId();
    final wallets =
        await _client.from('wallets').select('balance').eq('user_id', userId);
    return wallets.fold<int>(
      0,
      (sum, row) => sum + (row['balance'] as num? ?? 0).round(),
    );
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId != null) return userId;
    throw const AiEntryException(
      code: 'unauthorized',
      message: 'Please sign in to manage wallets.',
      status: 401,
    );
  }

  Map<String, dynamic> _record(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
