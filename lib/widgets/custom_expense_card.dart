import 'package:budgets/core/theme.dart';
import 'package:budgets/provider/app_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpenseTile extends ConsumerStatefulWidget {
  const ExpenseTile({
    super.key,
    required this.designation,
    required this.category,
    required this.amount,
    required this.date,
  });

  final String designation;
  final String category;
  final String amount;
  final DateTime date;

  @override
  ConsumerState<ExpenseTile> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends ConsumerState<ExpenseTile> {
  @override
  Widget build(BuildContext context) {
    final globalTheme = ref.watch(globalThemeProvider);

    bool isDarkMode = globalTheme == Brightness.dark;

    return ListTile(
      visualDensity: VisualDensity.standard,
      leading: CircleAvatar(
        backgroundColor:
            isDarkMode ? AppTheme.primaryLight : AppTheme.secondaryLight,
        child: const Icon(
          Icons.attach_money,
          color: Colors.white,
        ),
      ),
      title: Text(
        widget.designation,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.sp,
        ),
      ),
      subtitle: Text(
        widget.category,
        style: TextStyle(
          fontSize: 15.sp,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          Text(
            DateFormat('dd/MM/yyyy').format(widget.date),
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color.fromARGB(255, 109, 109, 109),
            ),
          ),
        ],
      ),
    );
  }
}
