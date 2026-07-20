import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceEntryQueryService {
  const FinanceEntryQueryService(this._client);

  final SupabaseClient _client;

  Future<List<FinanceEntry>> entriesForDate(
    String userId,
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day + 1);
    final results = await Future.wait([
      _transactionRows(userId, start, end),
      _transferRows(userId, start, end),
    ]);
    final entries = [...results[0], ...results[1]]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List.unmodifiable(entries);
  }

  Future<Set<DateTime>> activityDatesForMonth(
    String userId,
    DateTime month,
  ) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final range = (
      start.toUtc().toIso8601String(),
      end.toUtc().toIso8601String(),
    );
    final results = await Future.wait([
      _client
          .from('transaction')
          .select('date')
          .eq('user_id', userId)
          .gte('date', range.$1)
          .lt('date', range.$2),
      _client
          .from('wallet_transfers')
          .select('occurred_at')
          .eq('user_id', userId)
          .gte('occurred_at', range.$1)
          .lt('occurred_at', range.$2),
    ]);
    return {
      for (final row in results.expand((rows) => rows))
        if (_activityDate(row) case final date?) date,
    };
  }

  Future<List<FinanceEntry>> _transactionRows(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _client
        .from('transaction')
        .select(
          'id,title,description,amount,date,transaction_type,currency_code,'
          'categories(name,emoji,icon_key)',
        )
        .eq('user_id', userId)
        .gte('date', start.toUtc().toIso8601String())
        .lt('date', end.toUtc().toIso8601String());
    return rows
        .map((row) => FinanceEntry.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<List<FinanceEntry>> _transferRows(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _client
        .from('wallet_transfers')
        .select(
          'id,amount,currency_code,description,occurred_at,'
          'from_wallet:wallets!wallet_transfer_from_wallet_fkey(name),'
          'to_wallet:wallets!wallet_transfer_to_wallet_fkey(name)',
        )
        .eq('user_id', userId)
        .gte('occurred_at', start.toUtc().toIso8601String())
        .lt('occurred_at', end.toUtc().toIso8601String());
    return rows.map((row) {
      final value = Map<String, dynamic>.from(row);
      final from = _record(value['from_wallet'])['name'] ?? 'wallet';
      final to = _record(value['to_wallet'])['name'] ?? 'wallet';
      return FinanceEntry.fromJson({
        ...value,
        'entry_type': 'transfer',
        'title': 'Moved from $from to $to',
        'date': value['occurred_at'],
        'transaction_type': 'transfer',
        'category': {
          'name': 'Transfer',
          'emoji': '↔',
          'icon_key': 'transfer',
        },
      });
    }).toList(growable: false);
  }

  Map<String, dynamic> _record(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  DateTime? _activityDate(Map<String, dynamic> row) {
    final value = row['date'] ?? row['occurred_at'];
    final parsed = value is String ? DateTime.tryParse(value)?.toLocal() : null;
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }
}
