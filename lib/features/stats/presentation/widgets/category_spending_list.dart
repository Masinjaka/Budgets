import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/stats/domain/models/monthly_stats.dart';
import 'package:flutter/material.dart';

class CategorySpendingList extends StatelessWidget {
  const CategorySpendingList({
    required this.categories,
    required this.total,
    required this.currencyCode,
    super.key,
  });

  final List<CategoryStat> categories;
  final int total;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No expenses this month',
            style: TextStyle(color: Color(0xFF777777), fontSize: 12),
          ),
        ),
      );
    }
    return Column(
      children: categories.take(5).map((item) {
        final percentage = total == 0 ? 0 : item.amount / total;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDEDED),
                  shape: BoxShape.circle,
                ),
                child: Text(item.emoji, style: const TextStyle(fontSize: 17)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          formatAmountWithCurrency(item.amount, currencyCode),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        value: percentage.toDouble(),
                        color: Colors.black,
                        backgroundColor: const Color(0xFFE8E8E8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
