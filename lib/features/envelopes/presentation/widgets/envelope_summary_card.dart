import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:flutter/material.dart';

class EnvelopeSummaryCard extends StatelessWidget {
  const EnvelopeSummaryCard({
    required this.budget,
    required this.spent,
    required this.currencyCode,
    super.key,
  });

  final int budget;
  final int spent;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final remaining = budget - spent;
    return Container(
      width: double.infinity,
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
            'Available across envelopes',
            style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
          ),
          const SizedBox(height: 7),
          Text(
            formatAmountWithCurrency(remaining, currencyCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _value('Budget', budget),
              const SizedBox(width: 30),
              _value('Spent', spent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _value(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8F8F8F), fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          formatAmountWithCurrency(value, currencyCode),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
