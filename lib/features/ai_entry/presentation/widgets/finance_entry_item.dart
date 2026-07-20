import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/finance_entry_amount_badge.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/finance_entry_icon.dart';
import 'package:flutter/material.dart';

class FinanceEntryItem extends StatelessWidget {
  const FinanceEntryItem({required this.entry, super.key});

  final FinanceEntry entry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinanceEntryIcon(iconKey: entry.iconKey),
          const SizedBox(width: 17),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF606060),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: FinanceEntryAmountBadge(entry: entry),
          ),
        ],
      ),
    );
  }
}
