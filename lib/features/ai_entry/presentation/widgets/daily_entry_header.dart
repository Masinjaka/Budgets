import 'package:flutter/material.dart';

class DailyEntryHeader extends SliverPersistentHeaderDelegate {
  const DailyEntryHeader({
    required this.dateLabel,
    required this.summary,
  });

  final String dateLabel;
  final String summary;

  static const height = 44.0;

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
    return SizedBox.expand(
      child: ColoredBox(
        key: const Key('daily-entry-pinned-header'),
        color: const Color(0xFFFEFEFE),
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                summary,
                key: const Key('daily-entry-summary-label'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
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
    return dateLabel != oldDelegate.dateLabel || summary != oldDelegate.summary;
  }
}
