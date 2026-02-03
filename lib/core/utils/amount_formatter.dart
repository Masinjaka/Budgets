import 'package:intl/intl.dart';

/// Utilities for formatting amounts for display.
/// - formatAmountValue: 100000 -> "100 000"
/// - formatAmount: parses a string and formats it with space grouping
final NumberFormat _spaceFormatter = NumberFormat.decimalPattern('fr_FR');

String _normalizeSpaces(String input) {
  return input.replaceAll('\u00A0', ' ').replaceAll('\u202F', ' ');
}

double parseAmountInput(String raw) {
  final normalized = raw
      .replaceAll(' ', '')
      .replaceAll('\u00A0', '')
      .replaceAll('\u202F', '')
      .replaceAll(',', '');
  return double.tryParse(normalized) ?? 0;
}

String formatAmountValue(num? value) {
  final rounded = (value ?? 0).round();
  return _normalizeSpaces(_spaceFormatter.format(rounded));
}

String formatAmountWithCurrency(num? value, String currencyCode) {
  return '${formatAmountValue(value)} $currencyCode';
}

double convertFromMga(num? amountMga, double rate) {
  return (amountMga ?? 0) * rate;
}

double convertToMga(num? amount, double rate) {
  if (rate == 0) return 0;
  return (amount ?? 0) / rate;
}

String formatAmount(String raw) {
  final value = parseAmountInput(raw);
  return formatAmountValue(value);
}
