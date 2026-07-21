import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/stats/domain/models/monthly_stats.dart';
import 'package:flutter/material.dart';

class StatsOverviewCard extends StatelessWidget {
  const StatsOverviewCard({required this.stats, super.key});

  final MonthlyStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Net this month',
            style: TextStyle(color: Color(0xFFAFAFAF), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            formatAmountWithCurrency(stats.balance, stats.currencyCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 19),
          Row(
            children: [
              Expanded(
                child: _value(
                  'Income',
                  stats.income,
                  const Color(0xFF75C58C),
                ),
              ),
              Expanded(
                child: _value(
                  'Expenses',
                  stats.expenses,
                  const Color(0xFFF07868),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _value(String label, int amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF969696), fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          formatAmountWithCurrency(amount, stats.currencyCode),
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
