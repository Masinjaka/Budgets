import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'currency_provider.g.dart';

/// Currency state holding the selected currency code, exchange rates, and last fetch time.
class CurrencyState {
  final String code;
  final Map<String, double> rates;
  final DateTime? fetchedAt;

  const CurrencyState({
    required this.code,
    required this.rates,
    this.fetchedAt,
  });

  CurrencyState copyWith({
    String? code,
    Map<String, double>? rates,
    DateTime? fetchedAt,
  }) {
    return CurrencyState(
      code: code ?? this.code,
      rates: rates ?? this.rates,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}

/// Default currency rates (relative to MGA as base).
const _defaultRates = <String, double>{
  'USD': 0.00022,
  'EUR': 0.00020,
  'GBP': 0.00017,
  'JPY': 0.034,
  'CNY': 0.0016,
  'INR': 0.018,
  'CAD': 0.00030,
  'AUD': 0.00034,
  'CHF': 0.00019,
  'ZAR': 0.0040,
  'KES': 0.028,
  'NGN': 0.17,
  'GHS': 0.0027,
  'XOF': 0.13,
  'XAF': 0.13,
};

const _currencyCodeKey = 'selected_currency_code';

/// AsyncNotifier for managing currency state.
@riverpod
class CurrencyController extends _$CurrencyController {
  @override
  Future<CurrencyState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_currencyCodeKey) ?? 'MGA';
    return CurrencyState(
      code: savedCode,
      rates: _defaultRates,
      fetchedAt: DateTime.now(),
    );
  }

  /// Update the selected currency code.
  Future<void> setCurrency(String code) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(code: code));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyCodeKey, code);
  }

  /// Refresh exchange rates (placeholder - would call an API in production).
  Future<void> refreshRates() async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncLoading<CurrencyState>();

    // In a real app, you would fetch rates from an API here.
    // For now, we just update the fetchedAt timestamp.
    await Future.delayed(const Duration(milliseconds: 500));

    state = AsyncData(current.copyWith(
      fetchedAt: DateTime.now(),
    ));
  }
}
