import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CategoryTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final Color backgroundColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;

  CategoryTabBarDelegate({
    required this.tabController,
    required this.backgroundColor,
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
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
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
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Dépenses'),
                Tab(text: 'Revenus'),
              ],
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
    if (oldDelegate is CategoryTabBarDelegate) {
      return backgroundColor != oldDelegate.backgroundColor ||
          labelColor != oldDelegate.labelColor ||
          unselectedLabelColor != oldDelegate.unselectedLabelColor ||
          indicatorColor != oldDelegate.indicatorColor;
    }
    return true;
  }
}
