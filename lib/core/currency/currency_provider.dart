import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/currency/exchange_rates.dart';
import 'package:budgets/core/currency/exchange_rates_datasource.dart';
import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'currency_provider.g.dart';

@riverpod
Future<ExchangeRates?> exchangeRates(Ref ref) async {
  const datasource = ExchangeRatesDataSource();
  return datasource.fetchLatest();
}

@Riverpod(keepAlive: true)
class CurrencyController extends _$CurrencyController {
  static const _fallbackCurrencyCodes = <String>{
    'MGA',
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'JPY',
    'CNY',
    'CHF',
    'ZAR',
    'KES',
  };

  @override
  Future<CurrencyState> build() async {
    final rates = await ref.watch(exchangeRatesProvider.future);
    final user = await ref.watch(userModelProvider.future);

    final defaultCode = _defaultCurrencyCode();
    final code = user?.currencyCode ?? defaultCode;

    if (user?.currencyCode == null) {
      await ref.read(userRepositoryProvider).updateCurrencyCode(code);
    }

    final rateMap = Map<String, double>.from(rates?.rates ?? {});
    for (final currencyCode in _fallbackCurrencyCodes) {
      rateMap.putIfAbsent(currencyCode, () => 1.0);
    }
    rateMap.putIfAbsent(code, () => 1.0);

    return CurrencyState(
      code: code,
      baseCode: rates?.baseCode ?? 'MGA',
      rates: rateMap,
      fetchedAt: rates?.fetchedAt,
    );
  }

  Future<void> setCurrency(String code) async {
    final current = state.value;
    if (current == null || code == current.code) return;
    await ref.read(userRepositoryProvider).updateCurrencyCode(code);
    state = AsyncData(current.copyWith(code: code));
  }

  String _defaultCurrencyCode() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final localeName = locale.toString();
    final formatter = NumberFormat.simpleCurrency(locale: localeName);
    final currencyName = formatter.currencyName;
    if (currencyName == null || currencyName.isEmpty) return 'MGA';
    return currencyName;
  }
}
