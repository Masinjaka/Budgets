import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Base class for empty state displays in planning tabs
class PlanningEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PlanningEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30.sp,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).hintColor.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for planning list items
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

/// Progress bar widget with color based on progress value
class PlanningProgressBar extends StatelessWidget {
  final double progress;
  final bool useWarningColors;

  const PlanningProgressBar({
    super.key,
    required this.progress,
    this.useWarningColors = false,
  });

  Color _getProgressColor(BuildContext context) {
    if (!useWarningColors) {
      return Theme.of(context).primaryColor;
    }
    if (progress > 0.9) return Colors.red;
    if (progress > 0.7) return Colors.orange;
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 1.h,
        backgroundColor: Theme.of(context).colorScheme.surface,
        valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(context)),
      ),
    );
  }
}

/// Card container for planning items
class PlanningCard extends StatelessWidget {
  final Widget child;

  const PlanningCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: child,
    );
  }
}
