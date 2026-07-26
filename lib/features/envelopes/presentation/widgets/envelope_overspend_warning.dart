import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/envelopes/domain/models/envelope.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class EnvelopeOverspendWarning extends StatelessWidget {
  const EnvelopeOverspendWarning({
    required this.envelope,
    this.displayCurrency,
    super.key,
  });

  final Envelope envelope;
  final CurrencyState? displayCurrency;

  @override
  Widget build(BuildContext context) {
    const warning = Color(0xFFD84A3A);
    final amount = displayCurrency?.convertToSelected(
          envelope.overspentAmount,
          envelope.currencyCode,
        ) ??
        envelope.overspentAmount;
    return Row(
      key: const Key('envelope-overspend-warning'),
      children: [
        const Icon(Icons.warning_rounded, color: warning, size: 17),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            context.l10n.overBudgetBy(
              formatAmountWithCurrency(
                amount,
                displayCurrency?.code ?? envelope.currencyCode,
                preserveFraction: true,
              ),
            ),
            style: const TextStyle(
              color: warning,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
