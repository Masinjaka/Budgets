import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/metric_surface_card.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class EnvelopeSummaryCard extends StatelessWidget {
  const EnvelopeSummaryCard({
    required this.budget,
    required this.spent,
    required this.currencyCode,
    this.displayCurrency,
    super.key,
  });

  final int budget;
  final int spent;
  final String currencyCode;
  final CurrencyState? displayCurrency;

  @override
  Widget build(BuildContext context) {
    final available = budget - spent;
    final cards = [
      MetricSurfaceCard(
        key: const Key('envelope-available-card'),
        label: context.l10n.availableAcrossEnvelopes,
        value: _amount(available),
        icon: Icons.savings_outlined,
        valueColor:
            available < 0 ? AppTheme.dangerColor : AppTheme.primaryGreen,
      ),
      MetricSurfaceCard(
        label: context.l10n.budget,
        value: _amount(budget),
        icon: Icons.account_balance_wallet_outlined,
      ),
      MetricSurfaceCard(
        label: context.l10n.spent,
        value: _amount(spent),
        icon: Icons.payments_outlined,
        valueColor: AppTheme.dangerColor,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Row(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                Expanded(child: cards[index]),
                if (index < cards.length - 1) const SizedBox(width: 6),
              ],
            ],
          );
        }
        return Column(
          children: [
            SizedBox(width: double.infinity, child: cards[0]),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: cards[1]),
                const SizedBox(width: 6),
                Expanded(child: cards[2]),
              ],
            ),
          ],
        );
      },
    );
  }

  String _amount(int value) => formatAmountWithCurrency(
        displayCurrency?.convertToSelected(value, currencyCode) ?? value,
        displayCurrency?.code ?? currencyCode,
        preserveFraction: true,
      );
}
