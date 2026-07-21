import 'package:budgets/features/envelopes/domain/models/envelope.dart';
import 'package:budgets/features/envelopes/domain/models/envelope_category.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';

abstract interface class EnvelopeRepository {
  Future<List<Envelope>> envelopesForMonth(DateTime month);

  Future<List<EnvelopeCategory>> expenseCategories();

  Future<List<WalletSummary>> wallets();

  Future<void> addEnvelope({
    required String name,
    required String categoryId,
    required int amount,
    required DateTime month,
    String? walletId,
  });

  Future<void> deleteEnvelope(String id);
}
