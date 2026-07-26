import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

export 'transaction_list_shimmer_list.dart';

class TransactionListShimmer extends StatelessWidget {
  final int itemCount;

  const TransactionListShimmer({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
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
          childCount: itemCount,
        ),
      ),
    );
  }
}
