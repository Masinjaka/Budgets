import 'package:budgets/features/envelopes/data/services/envelope_service.dart';
import 'package:budgets/features/envelopes/domain/models/envelope.dart';
import 'package:budgets/features/envelopes/domain/models/envelope_category.dart';
import 'package:budgets/features/envelopes/domain/repositories/envelope_repository.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';

class SupabaseEnvelopeRepository implements EnvelopeRepository {
  const SupabaseEnvelopeRepository(this._service);

  final EnvelopeService _service;

  @override
  Future<List<Envelope>> envelopesForMonth(DateTime month) async {
    final rows = await _service.envelopes(month);
    return rows.map((row) {
      final category = _record(row['categories']);
      final categoryId = row['category_id'] as String;
      return Envelope(
        id: row['id'] as String,
        name: row['name'] as String,
        categoryId: categoryId,
        categoryName: (category['name'] as String?) ?? 'Other',
        emoji: (category['emoji'] as String?) ?? '🧾',
        color: (category['color'] as String?) ?? 'FF9E9E9E',
        amount: (row['amount'] as num).round(),
        spent: (row['amount'] as num).round() -
            (row['remaining_amount'] as num).round(),
        currencyCode: (row['currency_code'] as String?) ?? 'MGA',
      );
    }).toList(growable: false);
  }

  @override
  Future<List<EnvelopeCategory>> expenseCategories() async {
    final rows = await _service.expenseCategories();
    return rows.map(EnvelopeCategory.fromJson).toList(growable: false);
  }

  @override
  Future<List<WalletSummary>> wallets() async {
    final rows = await _service.wallets();
    return rows.map(WalletSummary.fromJson).toList(growable: false);
  }

  @override
  Future<void> addEnvelope({
    required String name,
    required String categoryId,
    required int amount,
    required DateTime month,
    String? walletId,
  }) =>
      _service.addEnvelope(
        name: name,
        categoryId: categoryId,
        amount: amount,
        month: month,
        walletId: walletId,
      );

  @override
  Future<void> deleteEnvelope(String id) => _service.deleteEnvelope(id);

  Map<String, dynamic> _record(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}
