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
    if (currencyCode == baseCode) return 1.0;
    return rates[currencyCode] ?? 1.0;
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
