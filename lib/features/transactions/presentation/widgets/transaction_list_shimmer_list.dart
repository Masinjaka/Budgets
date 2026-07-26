import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TransactionListShimmerList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const TransactionListShimmerList({
    super.key,
    this.itemCount = 8,
    this.padding,
    this.physics = const NeverScrollableScrollPhysics(),
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      physics: physics,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 32),
      itemCount: itemCount,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0 || index % 3 == 0)
              Container(
                width: 120,
                height: 16,
                margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            Container(
              height: 64,
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
