import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/animated_finance_entry_list.dart';
import 'package:flutter/material.dart';

class DailyEntrySection extends StatelessWidget {
  const DailyEntrySection({
    required this.dateLabel,
    required this.entries,
    required this.isLoading,
    super.key,
  });

  final String dateLabel;
  final List<FinanceEntry> entries;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(_summary, style: const TextStyle(fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 28),
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 28),
              child: Text(
                'No entries for this date',
                style: TextStyle(color: Color(0xFF777777), fontSize: 12),
              ),
            )
          else
            AnimatedFinanceEntryList(entries: entries),
        ],
      ),
    );
  }

  String get _summary {
    final expenseCount = entries.where((entry) => entry.isExpense).length;
    final incomeCount = entries.where((entry) => entry.isIncome).length;
    final transferCount = entries.where((entry) => entry.isTransfer).length;
    if (transferCount == entries.length) {
      return '$transferCount '
          '${transferCount == 1 ? 'transfer' : 'transfers'}';
    }
    if (incomeCount == 0) {
      if (transferCount > 0) return '${entries.length} entries';
      return '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'}';
    }
    if (expenseCount == 0) {
      if (transferCount > 0) return '${entries.length} entries';
      return '$incomeCount ${incomeCount == 1 ? 'income' : 'incomes'}';
    }
    return '${entries.length} entries';
  }
}
