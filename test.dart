import 'package:intl/intl.dart';

void main() {
  final _spaceFormatter = NumberFormat.decimalPattern('fr_FR');
  print(_spaceFormatter.format(12345.6789123));

  final customFormatter = NumberFormat.decimalPattern('fr_FR')
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = 20;

  print(customFormatter.format(12345.6789123));
  print(customFormatter.format(12345.0));
  print(customFormatter.format(12345));
}
