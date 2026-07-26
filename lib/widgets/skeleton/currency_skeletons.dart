import 'package:flutter/material.dart';
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
          SizedBox(height: 96),
          // Search bar skeleton
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Section title skeleton
          Container(
            width: 100,
            height: 16,
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(height: 8),
          // Currency card skeletons
          ...List.generate(8, (index) => _buildCurrencyCardSkeleton(theme)),
        ],
      ),
    );
  }

  Widget _buildCurrencyCardSkeleton(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(width: 16),
                // Currency code text
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            // Symbol text
            Container(
              width: 32,
              height: 16,
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
