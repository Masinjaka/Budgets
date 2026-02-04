import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton for CurrencySelectionPage - matches the exact structure
/// of the currency selection page with search bar and currency cards
class CurrencyPageSkeleton extends StatelessWidget {
  const CurrencyPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.onSurface.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          // Search bar skeleton
          Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Container(
              width: double.infinity,
              height: 6.h,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(5.w),
              ),
            ),
          ),
          // Section title skeleton
          Container(
            width: 25.w,
            height: 2.h,
            margin: EdgeInsets.only(bottom: 1.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(height: 1.h),
          // Currency card skeletons
          ...List.generate(8, (index) => _buildCurrencyCardSkeleton(theme)),
        ],
      ),
    );
  }

  Widget _buildCurrencyCardSkeleton(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(5.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon container
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                SizedBox(width: 4.w),
                // Currency code text
                Container(
                  width: 15.w,
                  height: 2.h,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            // Symbol text
            Container(
              width: 8.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
