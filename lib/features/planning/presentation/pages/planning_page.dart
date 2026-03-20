import 'package:budgets/features/planning/presentation/widgets/add_budget_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/add_goal_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/budgets_tab_content.dart';
import 'package:budgets/features/planning/presentation/widgets/goals_tab_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Planning page with three tabs: Budgets, Goals, and Subscriptions
class PlanningPage extends ConsumerStatefulWidget {
  const PlanningPage({super.key});

  @override
  ConsumerState<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends ConsumerState<PlanningPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentTabIndex = 0;

  static const _tabLabels = ['Budgets', 'Objectifs'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this)
      ..addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (!mounted || _currentTabIndex == _tabController.index) {
      return;
    }
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  void _showAddDialog() {
    if (_currentTabIndex == 0) {
      AddBudgetBottomSheet.show(context);
    } else if (_currentTabIndex == 1) {
      AddGoalBottomSheet.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: theme.scaffoldBackgroundColor,
          scrolledUnderElevation: 0,
          titleSpacing: 8.w,
          title: Text(
            'Planification',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(8.h),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 1.h),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.all(1.w),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.tabBarTheme.indicatorColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: theme.tabBarTheme.labelColor,
                  unselectedLabelColor: theme.tabBarTheme.unselectedLabelColor?.withValues(alpha: 0.7),
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
                  tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: 13.w,
          height: 13.w,
          child: FloatingActionButton(
            heroTag: 'planningFab',
            onPressed: _showAddDialog,
            backgroundColor: theme.primaryColor,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            BudgetsTabContent(),
            GoalsTabContent(),
          ],
        ),
      ),
    );
  }
}
