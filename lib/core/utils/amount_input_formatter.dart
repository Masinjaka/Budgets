import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove anything that's not a digit.
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanText.isEmpty) {
      return TextEditingValue.empty;
    }

    // Parse the number.
    int? value = int.tryParse(cleanText);
    if (value == null) {
      return oldValue;
    }
    
    // Format the number.
    final formatter = NumberFormat("#,##0", "en_US");
    String formattedText = formatter.format(value);
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
