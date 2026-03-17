import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
