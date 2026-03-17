import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

export 'transaction_list_shimmer_list.dart';

class TransactionListShimmer extends StatelessWidget {
  final int itemCount;

  const TransactionListShimmer({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
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
          childCount: itemCount,
        ),
      ),
    );
  }
}
