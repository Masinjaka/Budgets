import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.onTap,
  });

  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            )),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(0.8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.w),
              color: AppTheme.secondaryDark,
              
            ),
            child: Icon(Icons.arrow_right_alt_sharp,size: 18.sp,),
          ),
        )
    ],);
  }
}