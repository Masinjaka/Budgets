/// Utilities for formatting amounts for display.
/// - formatWithSpaces: 1000 -> "1 000"
/// - formatAmount: >= 1 000 uses compact K/M with up to one decimal (e.g., 1.2 K, 20 K), otherwise spaced grouping
String formatWithSpaces(int value) {
  final s = value.toString();
  return s.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]} ',
  );
}

String _trimTrailingZeros(String s) {
  if (!s.contains('.')) return s;
  s = s.replaceAll(RegExp(r'\.0+\n$'), '');
  // If regex above didn't match due to formatting, do a generic trim
  if (s.endsWith('.0')) return s.substring(0, s.length - 2);
  return s;
}

String formatAmount(String raw) {
  final normalized = raw.replaceAll(' ', '').replaceAll(',', '.');
  final value = double.tryParse(normalized) ?? 0;
  final absVal = value.abs();

  String withUnit(double scaled, String unit) {
    // One decimal, but trim trailing .0
    final fixed = scaled.toStringAsFixed(1);
    final trimmed = _trimTrailingZeros(fixed);
    return '$trimmed $unit';
  }

  if (absVal >= 1000000) {
    final scaled = value / 1000000; // millions
    return withUnit(scaled, 'M');
  }
  if (absVal >= 1000) {
    final scaled = value / 1000; // thousands
    return withUnit(scaled, 'K');
  }

  return formatWithSpaces(value.round());
}
