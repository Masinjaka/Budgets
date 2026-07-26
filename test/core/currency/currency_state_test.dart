import 'package:budgets/core/currency/currency_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyState.convertToSelected', () {
    const currency = CurrencyState(
      code: 'EUR',
      baseCode: 'MGA',
      rates: {'USD': 0.00022, 'EUR': 0.0002},
    );

    test('converts a base-currency amount into the selected currency', () {
      expect(currency.convertToSelected(100000, 'MGA'), 20);
    });

    test('converts a non-base amount through the base currency', () {
      expect(currency.convertToSelected(22, 'USD'), closeTo(20, 0.0001));
    });

    test('normalizes currency codes', () {
      expect(currency.convertToSelected(100000, 'mga'), 20);
    });

    test('converts selected currency input back to MGA storage units', () {
      expect(currency.convertSelectedToMga(200), 1000000);
    });

    test('keeps selected MGA input unchanged', () {
      final mga = currency.copyWith(code: 'MGA');

      expect(mga.convertSelectedToMga(200), 200);
    });
  });
}
