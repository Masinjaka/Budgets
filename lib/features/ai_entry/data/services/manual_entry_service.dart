import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/home/domain/errors/wallet_selection_required_exception.dart';
import 'package:budgets/features/home/domain/errors/insufficient_funds_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManualEntryService {
  const ManualEntryService(this._client);

  final SupabaseClient _client;

  Future<List<ManualEntryCategory>> categories() async {
    final rows = await _client
        .from('categories')
        .select('id,name,emoji,transaction_type')
        .order('name');
    return rows
        .map(
          (row) => ManualEntryCategory.fromJson(
            Map<String, dynamic>.from(row),
          ),
        )
        .toList(growable: false);
  }

  Future<FinanceEntry> add(ManualEntryInput input) async {
    late final dynamic response;
    try {
      response = await _client.rpc(
        'create_manual_finance_entry',
        params: {
          'p_title': input.title,
          'p_description': input.description,
          'p_amount': input.amount,
          'p_occurred_at': input.occurredAt.toUtc().toIso8601String(),
          'p_transaction_type': input.transactionType,
          'p_category_id': input.categoryId,
          'p_source_wallet_id': input.sourceWalletId,
          'p_period_month': _dateKey(input.occurredAt),
          'p_use_all_wallets': input.useAllWallets,
        },
      );
    } on PostgrestException catch (error) {
      final values = _fundValues(error.message);
      if (error.message.contains('wallet_consent_required:')) {
        throw WalletSelectionRequiredException(
          requiredAmount: values.$1,
          availableAmount: values.$2,
        );
      }
      if (error.message.contains('insufficient_funds:')) {
        throw InsufficientFundsException(
          requiredAmount: values.$1,
          availableAmount: values.$2,
        );
      }
      rethrow;
    }
    final row = response is Map
        ? Map<String, dynamic>.from(response)
        : <String, dynamic>{};
    return FinanceEntry.fromJson(row);
  }

  (int, int) _fundValues(String message) {
    final marker = message.contains('wallet_consent_required:')
        ? 'wallet_consent_required:'
        : 'insufficient_funds:';
    final values = message.split(marker).last.split(':');
    final required = int.tryParse(values.first.split(' ').first) ?? 0;
    final available =
        values.length > 1 ? int.tryParse(values[1].split(' ').first) ?? 0 : 0;
    return (required, available);
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-01';
}
