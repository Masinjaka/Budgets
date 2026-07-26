import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/core/ui/privacy_text.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinanceEntryAmountBadge extends StatelessWidget {
  const FinanceEntryAmountBadge({
    required this.entry,
    this.currencyState,
    super.key,
  });

  static const incomeBackground = Color(0xFFB9E5C7);
  static const expenseBackground = Color(0xFFF3C1C1);
  static const transferBackground = Color(0xFFB9D5F5);

  final FinanceEntry entry;
  final CurrencyState? currencyState;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: Key('finance-entry-amount-badge-${entry.id}'),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: PrivacyText(
          _amountLabel,
          textKey: Key('finance-entry-amount-${entry.id}'),
          maxLines: 1,
          style: const TextStyle(
            color: AppTheme.interactiveTextColor,
            fontSize: AppTypography.caption,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color get _backgroundColor => entry.isTransfer
      ? transferBackground
      : entry.isExpense
          ? expenseBackground
          : incomeBackground;

  String get _amountLabel {
    final currency = currencyState;
    if (currency == null) return _storedAmountLabel;
    final amount = currency.convertToSelected(
      entry.amount,
      entry.currencyCode,
    );
    final formatted = formatAmountWithCurrency(
      amount,
      currency.code,
      preserveFraction: true,
    );
    final sign = entry.isExpense || entry.isTransfer ? '-' : '+';
    return '$sign$formatted';
  }

  String get _storedAmountLabel {
    final amount = NumberFormat('#,##0.##', 'en_US')
        .format(entry.amount)
        .replaceAll(',', ' ');
    final sign = entry.isExpense || entry.isTransfer ? '-' : '+';
    return switch (entry.currencyCode) {
      'MGA' => '$sign$amount Ar',
      'USD' => '$sign\$ $amount',
      'EUR' => '$sign€ $amount',
      _ => '$sign$amount ${entry.currencyCode}',
    };
  }
}
