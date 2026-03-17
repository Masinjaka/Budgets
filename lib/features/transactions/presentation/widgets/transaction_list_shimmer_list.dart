import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

class TransactionListShimmerList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const TransactionListShimmerList({
    super.key,
    this.itemCount = 8,
    this.padding,
    this.physics = const NeverScrollableScrollPhysics(),
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      physics: physics,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 6.w),
      itemCount: itemCount,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0 || index % 3 == 0)
              Container(
                width: 30.w,
                height: 2.h,
                margin: EdgeInsets.fromLTRB(0, 2.w, 0, 2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(6.w),
                ),
              ),
            Container(
              height: 8.h,
              margin: EdgeInsets.only(bottom: 1.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(6.w),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
