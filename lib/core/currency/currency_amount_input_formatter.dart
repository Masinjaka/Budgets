import 'package:flutter/services.dart';

class CurrencyAmountInputFormatter extends TextInputFormatter {
  const CurrencyAmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = _sanitize(newValue.text);
    final baseOffset = _offsetAfterSanitizing(
      newValue.text,
      newValue.selection.baseOffset,
    );
    final extentOffset = _offsetAfterSanitizing(
      newValue.text,
      newValue.selection.extentOffset,
    );
    return TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: baseOffset,
        extentOffset: extentOffset,
      ),
    );
  }

  String _sanitize(String value) {
    final result = StringBuffer();
    var hasDecimal = false;
    for (final character in value.split('')) {
      if (_isDigit(character)) {
        result.write(character);
      } else if (!hasDecimal && (character == '.' || character == ',')) {
        result.write('.');
        hasDecimal = true;
      }
    }
    return result.toString();
  }

  int _offsetAfterSanitizing(String value, int offset) {
    if (offset < 0) return 0;
    return _sanitize(value.substring(0, offset.clamp(0, value.length))).length;
  }

  bool _isDigit(String character) {
    final codeUnit = character.codeUnitAt(0);
    return codeUnit >= 48 && codeUnit <= 57;
  }
}
