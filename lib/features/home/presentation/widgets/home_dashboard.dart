import 'package:budgets/features/home/domain/models/home_expense.dart';
import 'package:budgets/features/home/presentation/widgets/chat_input_bar.dart';
import 'package:budgets/features/home/presentation/widgets/daily_expense_section.dart';
import 'package:budgets/features/home/presentation/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    required this.today,
    required this.selectedDate,
    required this.drawerProgress,
    required this.onMenuPressed,
    super.key,
  });

  final DateTime today;
  final DateTime selectedDate;
  final Animation<double> drawerProgress;
  final VoidCallback onMenuPressed;

  static const _expenses = [
    HomeExpense(
      title: 'Burgers & Fries',
      category: 'Foods & Drinks',
      amount: '-\$ 3.99',
      kind: HomeExpenseKind.food,
    ),
    HomeExpense(
      title: 'Gift',
      category: 'Shopping',
      amount: '-\$ 3.99',
      kind: HomeExpenseKind.shopping,
    ),
    HomeExpense(
      title: 'Alcohol',
      category: 'Foods & Drinks',
      amount: '-\$ 3.99',
      kind: HomeExpenseKind.food,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateUtils.isSameDay(selectedDate, today)
        ? 'Today, ${DateFormat('d MMMM').format(selectedDate)}'
        : DateFormat('EEEE, d MMMM').format(selectedDate);
    return ColoredBox(
      color: const Color(0xFFFEFEFE),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth =
              constraints.maxWidth > 480 ? 480.0 : constraints.maxWidth;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: SafeArea(
                minimum: const EdgeInsets.only(top: 44, bottom: 4),
                child: Column(
                  children: [
                    HomeHeader(
                      drawerProgress: drawerProgress,
                      onMenuPressed: onMenuPressed,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 40),
                        child: DailyExpenseSection(
                          dateLabel: dateLabel,
                          expenses: _expenses,
                        ),
                      ),
                    ),
                    const ChatInputBar(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
