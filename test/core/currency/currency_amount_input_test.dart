import 'package:budgets/core/currency/currency_amount_input.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usd = CurrencyState(
    code: 'USD',
    baseCode: 'MGA',
    rates: {'USD': 0.0002},
  );

  test('converts selected-currency input to MGA storage units', () {
    expect(CurrencyAmountInput.toMga('200', usd), 1000000);
  });

  test('formats an MGA storage amount in the selected currency', () {
    expect(CurrencyAmountInput.fromStored(1000000, 'MGA', usd), '200');
  });

  test('separates the numeric hint from the selected currency symbol', () {
    expect(CurrencyAmountInput.hint(usd), '0');
    expect(CurrencyAmountInput.symbol(usd), r'$');
  });
}
