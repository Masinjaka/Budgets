import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionFilterCategorySkeleton extends StatelessWidget {
  const TransactionFilterCategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 10,
      children: List.generate(
        7,
        (index) => Container(
          width: 40 + Random().nextDouble() * (160 - 40),
          height: 33.6,
          margin: EdgeInsets.only(right: 8),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 216, 216, 216),
            borderRadius: BorderRadius.circular(20),
          ),
        ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: const Duration(seconds: 1),
              color: Colors.white,
            ),
      ),
    );
  }
}
