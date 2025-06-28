import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomSkeleton extends StatelessWidget {
  const CustomSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.5.w,
      width: 1.w,
      decoration: const BoxDecoration(
        color: AppTheme.primary,
      ),
    );
  }
}
