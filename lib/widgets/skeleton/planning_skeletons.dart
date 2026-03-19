import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable shimmer bone — a single rounded rectangle placeholder.
class SkeletonBone extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const SkeletonBone({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 6),
      ),
    );
  }
}

/// Skeleton for a single budget list item — matches BudgetListItem layout:
/// emoji circle + category name on the left, amount + period on the right,
/// and a progress bar at the bottom.
class BudgetItemSkeleton extends StatelessWidget {
  const BudgetItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.only(bottom: 2.h),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emoji circle
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      // Category name
                      SkeletonBone(width: 22.w, height: 2.h),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Amount text
                      SkeletonBone(width: 28.w, height: 1.8.h),
                      SizedBox(height: 0.6.h),
                      // Period label
                      SkeletonBone(width: 16.w, height: 1.4.h),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              // Progress bar
              SkeletonBone(
                width: double.infinity,
                height: 0.8.h,
                borderRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for a single goal list item — matches GoalListItem layout:
/// image area on top, title + category + date, amount row, and progress bar.
class GoalItemSkeleton extends StatelessWidget {
  const GoalItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.only(bottom: 2.h),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 15.h,
                margin: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2.5.w),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + add button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBone(width: 30.w, height: 2.h),
                            SizedBox(height: 0.6.h),
                            SkeletonBone(width: 20.w, height: 1.5.h),
                            SizedBox(height: 0.6.h),
                            SkeletonBone(width: 25.w, height: 1.5.h),
                          ],
                        ),
                        // Add button circle
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    // Amount row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBone(width: 22.w, height: 1.8.h),
                        SkeletonBone(width: 22.w, height: 1.8.h),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    // Progress bar
                    SkeletonBone(
                      width: double.infinity,
                      height: 0.8.h,
                      borderRadius: 4,
                    ),
                    SizedBox(height: 0.5.h),
                    // Percentage text
                    SkeletonBone(width: 16.w, height: 1.4.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for category chip pills in loading state.
class CategoryChipsSkeleton extends StatelessWidget {
  const CategoryChipsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.onSurface.withAlpha(25),
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: List.generate(
          6,
          (index) => Container(
            width: 20.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton list for budget loading state.
class BudgetListSkeleton extends StatelessWidget {
  final int itemCount;

  const BudgetListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 2.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const BudgetItemSkeleton(),
    );
  }
}

/// Skeleton list for goal loading state.
class GoalListSkeleton extends StatelessWidget {
  final int itemCount;

  const GoalListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 2.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const GoalItemSkeleton(),
    );
  }
}
