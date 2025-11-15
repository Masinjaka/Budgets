import 'package:budgets/core/theme.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpenseTile extends ConsumerStatefulWidget {
  const ExpenseTile({
    super.key,
    required this.designation,
    required this.category,
    required this.amount,
    required this.date,
    required this.categoryColor,
    required this.categoryEmoji,
    required this.description,
    required this.categoryId,
  });

  final String designation;
  final String category;
  final String amount;
  final DateTime date;
  final Color categoryColor; // Default color, can be customized
  final String categoryEmoji;
  final String description;
  final String categoryId;

  @override
  ConsumerState<ExpenseTile> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends ConsumerState<ExpenseTile> {
  // Removed local formatting helpers in favor of shared utils

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(5.w),
      ),
      // Use LayoutBuilder to get tile width and constrain description to half
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double textMaxWidth = constraints.maxWidth * 0.5;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Text(
                        widget.categoryEmoji,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  // Constrain text column to half of the tile width to trigger earlier ellipsis
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: textMaxWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          widget.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color.fromARGB(255, 63, 65, 68),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ...existing code...
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MGA',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff303237),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "- ${formatAmount(widget.amount)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5.sp,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
