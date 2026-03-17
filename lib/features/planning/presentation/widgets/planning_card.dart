import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PlanningCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const PlanningCard({
    super.key,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: child,
    );
  }
}
