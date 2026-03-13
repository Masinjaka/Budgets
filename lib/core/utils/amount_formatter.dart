import 'package:intl/intl.dart';

/// Utilities for formatting amounts for display.
/// - formatAmountValue: 100000 -> "100 000"
/// - formatAmount: parses a string and formats it with space grouping
final NumberFormat _spaceFormatter = NumberFormat.decimalPattern('fr_FR');
final NumberFormat _spaceDecimalFormatter = NumberFormat('#,##0.##', 'fr_FR');

String _normalizeSpaces(String input) {
  return input.replaceAll('\u00A0', ' ').replaceAll('\u202F', ' ');
}

double parseAmountInput(String raw) {
  if (raw.trim().isEmpty) return 0;

  final hasNegative = raw.contains('-');
  var normalized = _normalizeSpaces(raw).replaceAll(',', '');
  normalized = normalized.replaceAll(RegExp(r'[^0-9.]'), '');

  final firstDot = normalized.indexOf('.');
  if (firstDot != -1) {
    final before = normalized.substring(0, firstDot + 1);
    final after = normalized.substring(firstDot + 1).replaceAll('.', '');
    normalized = '$before$after';
  }

  if (normalized.startsWith('.')) {
    normalized = '0$normalized';
  }

  if (normalized.isEmpty || normalized == '.') return 0;
  final parsed = double.tryParse(normalized) ?? 0;
  return hasNegative ? -parsed : parsed;
}

String formatAmountValue(num? value, {bool preserveFraction = false}) {
  if (!preserveFraction) {
    final rounded = (value ?? 0).round();
    return _normalizeSpaces(_spaceFormatter.format(rounded));
  }

  final amount = value ?? 0;
  final normalizedAmount = amount.abs() < 0.005 ? 0 : amount;
  return _normalizeSpaces(_spaceDecimalFormatter.format(normalizedAmount))
      .replaceAll(',', '.');
}

String formatAmountWithCurrency(
  num? value,
  String currencyCode, {
  bool preserveFraction = false,
}) {
  final symbol = currencySymbolForCode(currencyCode);
  final formatted =
      formatAmountValue(value, preserveFraction: preserveFraction);
  if (isSuffixCurrency(currencyCode)) {
    return '$formatted $symbol';
  }
  return '$symbol$formatted';
}

String currencySymbolForCode(String currencyCode) {
  final normalized = currencyCode.toUpperCase();
  if (normalized == 'MGA') return 'Ar';
  try {
    final symbol = NumberFormat.simpleCurrency(name: normalized).currencySymbol;
    if (symbol.trim().isEmpty) return normalized;
    return symbol;
  } catch (_) {
    return normalized;
  }
}

bool isSuffixCurrency(String currencyCode) {
  return currencyCode.toUpperCase() == 'MGA';
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
