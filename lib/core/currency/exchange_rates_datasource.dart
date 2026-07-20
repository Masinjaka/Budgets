import 'package:budgets/core/currency/exchange_rates.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExchangeRatesDataSource {
  const ExchangeRatesDataSource();

  Future<ExchangeRates?> fetchLatest() async {
    final row = await Supabase.instance.client
        .from('exchange_rates')
        .select('base, rates, fetched_at')
        .order('fetched_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : ExchangeRates.fromJson(row);
  }
}
