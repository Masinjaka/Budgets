import 'package:budgets/features/home/domain/models/home_expense.dart';
import 'package:budgets/features/home/presentation/widgets/expense_list_item.dart';
import 'package:flutter/material.dart';

class DailyExpenseSection extends StatelessWidget {
  const DailyExpenseSection({
    required this.dateLabel,
    required this.expenses,
    super.key,
  });

  final String dateLabel;
  final List<HomeExpense> expenses;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${expenses.length} expenses',
                style: const TextStyle(fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final expense in expenses) ExpenseListItem(expense: expense),
        ],
      ),
    );
  }
}
