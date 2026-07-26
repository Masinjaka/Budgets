import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/stats/domain/models/monthly_stats.dart';
import 'package:budgets/features/stats/presentation/widgets/category_spending_list.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class StatsTopSpendingCard extends StatelessWidget {
  const StatsTopSpendingCard({
    required this.stats,
    this.displayCurrency,
    super.key,
  });

  final MonthlyStats stats;
  final CurrencyState? displayCurrency;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.topSpending,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          CategorySpendingList(
            categories: stats.expenseCategories,
            total: stats.expenses,
            currencyCode: stats.currencyCode,
            displayCurrency: displayCurrency,
          ),
        ],
      ),
    );
  }
}
