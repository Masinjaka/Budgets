import 'package:budgets/core/theme.dart';
import 'package:budgets/provider/subcategories_provider.dart';
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
  @override
  Widget build(BuildContext context) {

    final asyncSubcategories = ref.watch(subcategoriesProvider(widget.categoryId));

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(
          color: AppTheme.borderColorDark,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.categoryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 0.2.h),
                  asyncSubcategories.when(
                    data: (subcategories) {
                      if (subcategories.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Text("${subcategories.length} sous-catégorie(s)",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xff303237),
                        ),
                      );
                    },
                    loading: () => Container(
                      
                      height: 1.h,
                      width: 20.w,
                      decoration: BoxDecoration(
                        color: AppTheme.borderColorDark,
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                    ),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                ],
              ),
            ],
          ),
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
              SizedBox(height: 0.5.h),
              Text(
                widget.amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
