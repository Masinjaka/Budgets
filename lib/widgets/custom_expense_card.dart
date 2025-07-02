import 'package:budgets/core/theme.dart';
import 'package:budgets/pages/expenses/page/expense_page.dart';
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

    return Padding(
          padding: EdgeInsets.only(bottom: 1.2.h),
          child: Container(
            padding: EdgeInsets.all(3.w),
            height: 9.h,
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.secondaryDark: null,
              border: Border.all(color: isDarkMode ? Colors.transparent: Colors.black),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.designation,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5.sp,
                      ),
                    ),
                    Pills(text: widget.category),
                  ],
                ),
                Column(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.amount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5.sp,
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
                )
              ],
            ),
          ),
        );
  }
}