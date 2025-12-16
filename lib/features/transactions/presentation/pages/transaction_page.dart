import 'package:budgets/widgets/custom_action_button.dart';
import 'package:budgets/features/transactions/presentation/pages/expense_tab_content.dart';
import 'package:budgets/features/transactions/presentation/pages/income_tab_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage>
    with TickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  // Animation controller for SliverAppBar
  late AnimationController _appBarAnimationController;
  late Animation<double> _appBarAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarAnimation = CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.easeInOut,
    );
    // Start with app bar visible
    _appBarAnimationController.value = 1.0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // Moved SliverAppBar from transaction list page
              AnimatedBuilder(
                animation: _appBarAnimation,
                builder: (context, child) {
                  return SliverAppBar(
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    pinned: true,
                    floating: true,
                    expandedHeight: _appBarAnimation.value * kToolbarHeight,
                    toolbarHeight: _appBarAnimation.value * kToolbarHeight,
                    elevation: _appBarAnimation.value * 4,
                    titleSpacing: 6.w,
                    title: _appBarAnimation.value > 0.1
                        ? Opacity(
                            opacity: _appBarAnimation.value,
                            child: Transform.translate(
                              offset:
                                  Offset(0, (1 - _appBarAnimation.value) * -20),
                              child: Text(
                                'Transactions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withAlpha(_appBarAnimation.value > 0.1
                                          ? 255
                                          : 0),
                                ),
                              ),
                            ),
                          )
                        : null,
                    centerTitle: false,
                    actions: _appBarAnimation.value > 0.1
                        ? [
                            Opacity(
                              opacity: _appBarAnimation.value,
                              child: Transform.translate(
                                offset: Offset(
                                    0, (1 - _appBarAnimation.value) * -20),
                                child: ActionButton(
                                    icon: Icons.fullscreen,
                                    iconColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    onPressed: () {}),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Opacity(
                              opacity: _appBarAnimation.value,
                              child: Transform.translate(
                                offset: Offset(
                                    0, (1 - _appBarAnimation.value) * -20),
                                child: ActionButton(
                                    icon: Icons.add,
                                    iconColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    onPressed: () {
                                      // Get the current active tab to determine transaction type
                                      final isExpenseTab =
                                          _tabController.index == 0;
                                      final transactionType =
                                          isExpenseTab ? 'expense' : 'income';
                                      context.push(
                                          "/add-transaction?type=$transactionType");
                                    }),
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ]
                        : [],
                  );
                },
              ),
              // Tab view positioned at top left - pinned to not scroll with content
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  tabController: _tabController,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                  unselectedLabelColor: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withAlpha(128),
                  indicatorColor: Theme.of(context).primaryColor,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            physics:
                const NeverScrollableScrollPhysics(), // disable horizontal swipe
            children: [
              // Expenses tab - contains the transaction list content
              TransactionTabContent(
                appBarAnimationController: _appBarAnimationController,
              ),
              // Income tab - contains the income content
              IncomeTabContent(
                appBarAnimationController: _appBarAnimationController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final Color backgroundColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;

  _TabBarDelegate({
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
  double get maxExtent => 5.h + 4.h; // Tab height + padding

  @override
  double get minExtent => 5.h + 4.h; // Same as maxExtent for fixed height

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    if (oldDelegate is _TabBarDelegate) {
      return backgroundColor != oldDelegate.backgroundColor ||
          labelColor != oldDelegate.labelColor ||
          unselectedLabelColor != oldDelegate.unselectedLabelColor ||
          indicatorColor != oldDelegate.indicatorColor;
    }
    return true;
  }
}
