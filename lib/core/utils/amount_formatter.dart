import 'package:intl/intl.dart';

/// Utilities for formatting amounts for display.
/// - formatAmountValue: 100000 -> "100 000"
/// - formatAmount: parses a string and formats it with space grouping
final NumberFormat _spaceFormatter = NumberFormat.decimalPattern('fr_FR');

String _normalizeSpaces(String input) {
  return input.replaceAll('\u00A0', ' ').replaceAll('\u202F', ' ');
}

String formatAmountValue(num? value, {bool includeCurrency = false}) {
  final rounded = (value ?? 0).round();
  final formatted = _normalizeSpaces(_spaceFormatter.format(rounded));
  return includeCurrency ? '$formatted MGA' : formatted;
}

String formatAmount(String raw) {
  final normalized = raw
      .replaceAll(' ', '')
      .replaceAll('\u00A0', '')
      .replaceAll('\u202F', '')
      .replaceAll(',', '.');
  final value = double.tryParse(normalized) ?? 0;
  return formatAmountValue(value);
}
