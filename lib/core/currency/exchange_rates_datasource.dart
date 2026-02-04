import 'package:budgets/core/currency/exchange_rates.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExchangeRatesDataSource {
  ExchangeRatesDataSource(this._client);
  final SupabaseClient _client;

  Future<ExchangeRates?> fetchLatest() async {
    final data = await _client
        .from('exchange_rates')
        .select('base, rates, fetched_at')
        .order('fetched_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return ExchangeRates.fromJson(data);
  }
}
