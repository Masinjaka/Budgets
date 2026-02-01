import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Tab bar delegate for planning page with pill-style indicator
class PlanningTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final Color backgroundColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final List<String> tabLabels;

  PlanningTabBarDelegate({
    required this.tabController,
    required this.backgroundColor,
    required this.tabLabels,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 0.h),
        child: Center(
          child: Container(
            width: 90.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(50),
            ),
            padding: EdgeInsets.all(1.w),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(
                color: indicatorColor ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(50),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: unselectedLabelColor,
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  return states.contains(WidgetState.focused)
                      ? null
                      : Colors.transparent;
                },
              ),
              splashFactory: NoSplash.splashFactory,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: tabLabels.map((label) => Tab(text: label)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 5.h + 4.h;

  @override
  double get minExtent => 5.h + 4.h;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    if (oldDelegate is PlanningTabBarDelegate) {
      return backgroundColor != oldDelegate.backgroundColor ||
          labelColor != oldDelegate.labelColor ||
          unselectedLabelColor != oldDelegate.unselectedLabelColor ||
          indicatorColor != oldDelegate.indicatorColor;
    }
    return true;
  }
}
