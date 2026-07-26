import 'package:flutter/material.dart';
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
        padding: EdgeInsets.only(bottom: 16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      // Category name
                      SkeletonBone(width: 88, height: 16),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Amount text
                      SkeletonBone(width: 112, height: 14.4),
                      SizedBox(height: 4.8),
                      // Period label
                      SkeletonBone(width: 64, height: 11.2),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Progress bar
              SkeletonBone(
                width: double.infinity,
                height: 6.4,
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
        padding: EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 120,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            SkeletonBone(width: 120, height: 16),
                            SizedBox(height: 4.8),
                            SkeletonBone(width: 80, height: 12),
                            SizedBox(height: 4.8),
                            SkeletonBone(width: 100, height: 12),
                          ],
                        ),
                        // Add button circle
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Amount row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBone(width: 88, height: 14.4),
                        SkeletonBone(width: 88, height: 14.4),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Progress bar
                    SkeletonBone(
                      width: double.infinity,
                      height: 6.4,
                      borderRadius: 4,
                    ),
                    SizedBox(height: 4),
                    // Percentage text
                    SkeletonBone(width: 64, height: 11.2),
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
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          6,
          (index) => Container(
            width: 80,
            height: 32,
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
      padding: EdgeInsets.only(top: 16),
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
      padding: EdgeInsets.only(top: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const GoalItemSkeleton(),
    );
  }
}
