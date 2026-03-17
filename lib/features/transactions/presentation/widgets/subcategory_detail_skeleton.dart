import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

class SubcategoryDetailSkeleton extends StatelessWidget {
  const SubcategoryDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          2,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(context, width: 25.w),
                SizedBox(width: 2.w),
                _shimmerBox(context, width: 15.w),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(BuildContext context, {required double width}) {
    final base = Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(26) ??
        Colors.grey.withAlpha(26);
    final highlight =
        Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(51) ??
            Colors.grey.withAlpha(51);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: 2.5.h,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }
}
