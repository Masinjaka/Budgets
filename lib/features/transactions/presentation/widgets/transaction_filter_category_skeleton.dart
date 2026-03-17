import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionFilterCategorySkeleton extends StatelessWidget {
  const TransactionFilterCategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 2.5.w,
      children: List.generate(
        7,
        (index) => Container(
          width: 10.w + Random().nextDouble() * (40.w - 10.w),
          height: 4.2.h,
          margin: EdgeInsets.only(right: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 216, 216, 216),
            borderRadius: BorderRadius.circular(5.w),
          ),
        ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: const Duration(seconds: 1),
              color: Colors.white,
            ),
      ),
    );
  }
}
