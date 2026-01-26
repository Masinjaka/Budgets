import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton for TransactionTile widget - matches the exact structure
/// of the transaction tile with emoji box, text lines, and amount
class TransactionTileSkeleton extends StatelessWidget {
  const TransactionTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.onSurface.withOpacity(0.1),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.5.h),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji box placeholder
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                SizedBox(width: 3.w),
                // Text column placeholder
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category name placeholder
                    Container(
                      width: 25.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Description placeholder
                    Container(
                      width: 35.w,
                      height: 1.8.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Amount column placeholder
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // MGA label placeholder
                Container(
                  width: 10.w,
                  height: 1.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 0.8.h),
                // Amount placeholder
                Container(
                  width: 18.w,
                  height: 2.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// List of transaction tile skeletons for loading state
class TransactionListSkeleton extends StatelessWidget {
  final int itemCount;

  const TransactionListSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
        (index) => const TransactionTileSkeleton(),
      ),
    );
  }
}

/// Skeleton for the balance amount in Jumbotron widget
class JumbotronAmountSkeleton extends StatelessWidget {
  const JumbotronAmountSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.onSurface.withOpacity(0.1),
      child: Container(
        width: 45.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Skeleton for StatsHomeWidget - matches the bar chart card structure
class StatsHomeWidgetSkeleton extends StatelessWidget {
  const StatsHomeWidgetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.onSurface.withOpacity(0.1),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          // Legend skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendSkeleton(context),
              SizedBox(width: 4.w),
              _buildLegendSkeleton(context),
            ],
          ),
          SizedBox(height: 2.h),
          // Chart area skeleton with bars
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                // Varying heights for visual interest
                final heights = [0.4, 0.6, 0.3, 0.8, 0.5, 0.7, 0.45];
                return _buildBarSkeleton(context, heights[index]);
              }),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildLegendSkeleton(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(1.w),
          ),
        ),
        SizedBox(width: 2.w),
        Container(
          width: 15.w,
          height: 1.5.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildBarSkeleton(BuildContext context, double heightFactor) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 6.w,
          height: 14.h * heightFactor,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
        SizedBox(height: 0.8.h),
        // Day label skeleton
        Container(
          width: 5.w,
          height: 1.2.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
