import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/metric_surface_card.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/stats/domain/models/monthly_stats.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class StatsMetricsGrid extends StatelessWidget {
  const StatsMetricsGrid({
    required this.stats,
    this.displayCurrency,
    super.key,
  });

  final MonthlyStats stats;
  final CurrencyState? displayCurrency;

  @override
  Widget build(BuildContext context) {
    final cards = _cards(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.75,
            children: cards,
          );
        }
        return Column(
          children: [
            _row(cards[0], cards[1], 3, 2),
            const SizedBox(height: 6),
            _row(cards[2], cards[3], 2, 3),
            const SizedBox(height: 6),
            _row(cards[4], cards[5], 3, 2),
          ],
        );
      },
    );
  }

  Widget _row(Widget first, Widget second, int firstFlex, int secondFlex) {
    return Row(
      children: [
        Expanded(flex: firstFlex, child: first),
        const SizedBox(width: 6),
        Expanded(flex: secondFlex, child: second),
      ],
    );
  }

  List<Widget> _cards(BuildContext context) {
    final l10n = context.l10n;
    String amount(int value) => formatAmountWithCurrency(
          displayCurrency?.convertToSelected(value, stats.currencyCode) ??
              value,
          displayCurrency?.code ?? stats.currencyCode,
          preserveFraction: true,
        );
    return [
      MetricSurfaceCard(
        key: const Key('stats-net-card'),
        label: l10n.netThisMonth,
        value: amount(stats.balance),
        icon: Icons.account_balance_wallet_outlined,
      ),
      MetricSurfaceCard(
        key: const Key('stats-transactions-card'),
        label: l10n.transactions,
        value: '${stats.transactionCount}',
        icon: Icons.receipt_long_outlined,
        maskValue: false,
      ),
      MetricSurfaceCard(
        label: l10n.averagePerDay,
        value: amount(stats.averageDailySpend),
        icon: Icons.calendar_month_outlined,
      ),
      MetricSurfaceCard(
        label: l10n.expenses,
        value: amount(stats.expenses),
        icon: Icons.arrow_upward_rounded,
        valueColor: AppTheme.dangerColor,
      ),
      MetricSurfaceCard(
        label: l10n.income,
        value: amount(stats.income),
        icon: Icons.arrow_downward_rounded,
        valueColor: AppTheme.primaryGreen,
      ),
      MetricSurfaceCard(
        label: l10n.largestExpense,
        value: amount(stats.largestExpense),
        icon: Icons.payments_outlined,
      ),
    ];
  }
}
