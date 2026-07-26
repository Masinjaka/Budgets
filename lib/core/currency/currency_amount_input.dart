import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/utils/amount_formatter.dart';

class CurrencyAmountInput {
  const CurrencyAmountInput._();

  static int toMga(String raw, CurrencyState? currency) {
    final displayAmount = parseAmountInput(raw);
    return (currency?.convertSelectedToMga(displayAmount) ?? displayAmount)
        .round();
  }

  static String fromStored(
    num amount,
    String sourceCurrencyCode,
    CurrencyState? currency,
  ) {
    final displayAmount =
        currency?.convertToSelected(amount, sourceCurrencyCode) ?? amount;
    return formatAmountValue(
      displayAmount,
      preserveFraction: currency?.code != 'MGA',
    );
  }

  static String hint(CurrencyState? currency) {
    return formatAmountWithCurrency(0, currency?.code ?? 'MGA');
  }
}
