import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/core/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DailyEntryHeader extends SliverPersistentHeaderDelegate {
  const DailyEntryHeader({
    required this.dateLabel,
    required this.summary,
    this.collapseProgress,
    this.pinOffset = 0,
    this.expandedRadius = 0,
  });

  final String dateLabel;
  final String summary;
  final ValueListenable<double>? collapseProgress;
  final double pinOffset;
  final double expandedRadius;

  static const height = 44.0;
  static const surfaceColor = AppTheme.backgroundLight;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final scrollOffset = Scrollable.of(context).position.pixels;
    final isPinned = scrollOffset >= pinOffset - 0.5;
    final progress = collapseProgress?.value.clamp(0.0, 1.0) ?? 1.0;
    final radius = expandedRadius * (1 - progress);
    return SizedBox.expand(
      child: DecoratedBox(
        key: const Key('daily-entry-pinned-header'),
        decoration: BoxDecoration(
          color: isPinned
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isPinned ? radius : 0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 2, 30, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  key: const Key('daily-entry-date-label'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppTypography.supporting,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                summary,
                key: const Key('daily-entry-summary-label'),
                style: const TextStyle(
                  fontSize: AppTypography.supporting,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant DailyEntryHeader oldDelegate) {
    return dateLabel != oldDelegate.dateLabel ||
        summary != oldDelegate.summary ||
        collapseProgress != oldDelegate.collapseProgress ||
        pinOffset != oldDelegate.pinOffset ||
        expandedRadius != oldDelegate.expandedRadius;
  }
}
