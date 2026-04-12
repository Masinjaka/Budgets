import 'package:budgets/core/currency/exchange_rates.dart';
import 'package:budgets/core/powersync/powersync.dart' as powersync;

class ExchangeRatesDataSource {
  const ExchangeRatesDataSource();

  Future<ExchangeRates?> fetchLatest() async {
    final rows = await powersync.db.getAll('''
      SELECT base, rates, fetched_at
      FROM exchange_rates
      ORDER BY fetched_at DESC
      LIMIT 1
    ''');

    if (rows.isEmpty) return null;
    return ExchangeRates.fromJson(rows.first);
  }
}
