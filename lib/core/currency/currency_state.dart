class CurrencyState {
  final String code;
  final String baseCode;
  final Map<String, double> rates;
  final DateTime? fetchedAt;

  const CurrencyState({
    required this.code,
    required this.baseCode,
    required this.rates,
    this.fetchedAt,
  });

  double rateFor(String currencyCode) {
    final normalized = currencyCode.toUpperCase();
    if (normalized == baseCode.toUpperCase()) return 1.0;
    return rates[normalized] ?? 1.0;
  }

  double convertToSelected(num amount, String sourceCurrencyCode) {
    return convert(amount, from: sourceCurrencyCode, to: code);
  }

  double convertSelectedToMga(num amount) {
    return convert(amount, from: code, to: 'MGA');
  }

  double convert(
    num amount, {
    required String from,
    required String to,
  }) {
    final sourceRate = rateFor(from);
    if (sourceRate == 0) return 0;
    return amount / sourceRate * rateFor(to);
  }

  CurrencyState copyWith({
    String? code,
    String? baseCode,
    Map<String, double>? rates,
    DateTime? fetchedAt,
  }) {
    return CurrencyState(
      code: code ?? this.code,
      baseCode: baseCode ?? this.baseCode,
      rates: rates ?? this.rates,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
