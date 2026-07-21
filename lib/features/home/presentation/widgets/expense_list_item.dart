import 'package:budgets/features/home/domain/models/home_expense.dart';
import 'package:flutter/material.dart';

class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({required this.expense, super.key});

  final HomeExpense expense;

  @override
  Widget build(BuildContext context) {
    final icon = switch (expense.kind) {
      HomeExpenseKind.food => Icons.fastfood_outlined,
      HomeExpenseKind.shopping => Icons.shopping_cart_outlined,
    };

    return SizedBox(
      height: 66,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 21, color: Colors.black),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    expense.category,
                    style: const TextStyle(
                      color: Color(0xFF606060),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(expense.amount, style: const TextStyle(fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}
