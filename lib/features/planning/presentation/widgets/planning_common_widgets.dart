import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Base class for empty state displays in planning tabs
class PlanningEmptyState extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const PlanningEmptyState({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath)
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(
                  duration: 400.ms,
                ),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 22.5.sp,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 500.ms,
                  delay: 200.ms,
                  curve: Curves.easeOutCubic,
                )
                .fadeIn(
                  duration: 400.ms,
                  delay: 200.ms,
                ),

            SizedBox(height: 2.h),

            // Description
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 500.ms,
                  delay: 400.ms,
                  curve: Curves.easeOutCubic,
                )
                .fadeIn(
                  duration: 400.ms,
                  delay: 400.ms,
                ),
          ],
        ),
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
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 1.h,
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(context)),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}

/// Card container for planning items
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
