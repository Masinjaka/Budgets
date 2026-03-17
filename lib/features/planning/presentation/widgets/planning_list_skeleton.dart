import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PlanningListSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const PlanningListSkeleton({
    super.key,
    this.itemCount = 5,
    required this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 2.h),
      itemCount: itemCount,
      itemBuilder: (context, index) => Container(
        margin: EdgeInsets.only(bottom: 2.h),
        height: itemHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(4.w),
        ),
      ),
    );
  }
}
