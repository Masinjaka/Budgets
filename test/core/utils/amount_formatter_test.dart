import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatWithSpaces', () {
    test('formats small numbers without spaces', () {
      expect(formatWithSpaces(0), '0');
      expect(formatWithSpaces(1), '1');
      expect(formatWithSpaces(10), '10');
      expect(formatWithSpaces(100), '100');
      expect(formatWithSpaces(999), '999');
    });

    test('formats thousands with spaces', () {
      expect(formatWithSpaces(1000), '1 000');
      expect(formatWithSpaces(1234), '1 234');
      expect(formatWithSpaces(9999), '9 999');
    });

    test('formats ten thousands with spaces', () {
      expect(formatWithSpaces(10000), '10 000');
      expect(formatWithSpaces(12345), '12 345');
      expect(formatWithSpaces(99999), '99 999');
    });

    test('formats hundred thousands with spaces', () {
      expect(formatWithSpaces(100000), '100 000');
      expect(formatWithSpaces(123456), '123 456');
      expect(formatWithSpaces(999999), '999 999');
    });

    test('formats millions with spaces', () {
      expect(formatWithSpaces(1000000), '1 000 000');
      expect(formatWithSpaces(1234567), '1 234 567');
      expect(formatWithSpaces(9999999), '9 999 999');
    });

    test('formats ten millions with spaces', () {
      expect(formatWithSpaces(10000000), '10 000 000');
      expect(formatWithSpaces(12345678), '12 345 678');
    });

    test('handles negative numbers', () {
      expect(formatWithSpaces(-1000), '-1 000');
      expect(formatWithSpaces(-1234567), '-1 234 567');
    });
  });

  group('formatAmount', () {
    test('formats small amounts without unit', () {
      expect(formatAmount('0'), '0');
      expect(formatAmount('100'), '100');
      expect(formatAmount('999'), '999');
    });

    test('formats thousands with K unit', () {
      expect(formatAmount('1000'), '1 K');
      expect(formatAmount('1500'), '1.5 K');
      expect(formatAmount('2500'), '2.5 K');
      expect(formatAmount('10000'), '10 K');
      expect(formatAmount('12300'), '12.3 K');
      expect(formatAmount('999999'), '1000 K');
    });

    test('formats millions with M unit', () {
      expect(formatAmount('1000000'), '1 M');
      expect(formatAmount('1500000'), '1.5 M');
      expect(formatAmount('2500000'), '2.5 M');
      expect(formatAmount('10000000'), '10 M');
      expect(formatAmount('123400000'), '123.4 M');
    });

    test('handles string with spaces', () {
      expect(formatAmount('1 000'), '1 K');
      expect(formatAmount('1 000 000'), '1 M');
    });

    test('handles string with commas as decimal separator', () {
      expect(formatAmount('1000,5'), '1 K');
      expect(formatAmount('1500,0'), '1.5 K');
    });

    test('trims trailing zeros after decimal', () {
      expect(formatAmount('1000'), '1 K');
      expect(formatAmount('2000'), '2 K');
      expect(formatAmount('1000000'), '1 M');
    });

    test('handles negative amounts', () {
      expect(formatAmount('-1500'), '-1.5 K');
      expect(formatAmount('-1500000'), '-1.5 M');
    });

    test('handles invalid input gracefully', () {
      expect(formatAmount(''), '0');
      expect(formatAmount('abc'), '0');
    });
  });
}
