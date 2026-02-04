class ExchangeRates {
  final String baseCode;
  final Map<String, double> rates;
  final DateTime fetchedAt;

  const ExchangeRates({
    required this.baseCode,
    required this.rates,
    required this.fetchedAt,
  });

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final parsedRates = <String, double>{};

    rawRates.forEach((key, value) {
      final numValue = value is num ? value : double.tryParse(value.toString());
      if (numValue != null) {
        parsedRates[key] = numValue.toDouble();
      }
    });

    return ExchangeRates(
      baseCode: (json['base'] as String?) ?? 'MGA',
      rates: parsedRates,
      fetchedAt: DateTime.tryParse(json['fetched_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
