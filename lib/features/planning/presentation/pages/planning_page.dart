import 'package:budgets/features/planning/presentation/widgets/add_budget_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/add_goal_bottom_sheet.dart';
import 'package:budgets/features/planning/presentation/widgets/budgets_tab_content.dart';
import 'package:budgets/features/planning/presentation/widgets/goals_tab_content.dart';
import 'package:budgets/features/planning/presentation/widgets/subscriptions_tab_content.dart';
import 'package:budgets/features/planning/presentation/widgets/planning_tab_bar_delegate.dart';
import 'package:budgets/widgets/custom_action_button.dart';
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
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _appBarAnimationController;
  late Animation<double> _appBarAnimation;

  static const _tabLabels = ['Budgets', 'Objectifs', 'Abonnements'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(_onTabChange);
    _initAppBarAnimation();
  }

  void _initAppBarAnimation() {
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarAnimation = CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.easeInOut,
    );
    _appBarAnimationController.value = 1.0;
  }

  void _onTabChange() {
    // Rebuild to update add button visibility
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final currentIndex = _tabController.index;

    if (currentIndex == 0) {
      // Budgets tab
      AddBudgetBottomSheet.show(context);
    } else if (currentIndex == 1) {
      // Goals tab
      AddGoalBottomSheet.show(context);
    }
    // No action for Subscriptions tab (index 2)
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: false,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: _buildHeaderSlivers,
          body: TabBarView(
            controller: _tabController,
            children: const [
              BudgetsTabContent(),
              GoalsTabContent(),
              SubscriptionsTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeaderSlivers(
      BuildContext context, bool innerBoxIsScrolled) {
    return [
      _buildAnimatedAppBar(context),
      _buildTabBar(context),
    ];
  }

  Widget _buildAnimatedAppBar(BuildContext context) {
    return AnimatedBuilder(
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
          title: _buildAppBarTitle(context),
          centerTitle: false,
          actions: _buildAppBarActions(context),
        );
      },
    );
  }

  Widget? _buildAppBarTitle(BuildContext context) {
    if (_appBarAnimation.value <= 0.1) return null;

    return Opacity(
      opacity: _appBarAnimation.value,
      child: Transform.translate(
        offset: Offset(0, (1 - _appBarAnimation.value) * -20),
        child: Text(
          'Planification',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.color
                ?.withValues(alpha: _appBarAnimation.value > 0.1 ? 1 : 0),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    // Hide add button for Subscriptions tab (index 2)
    if (_appBarAnimation.value <= 0.1 || _tabController.index == 2) {
      return [];
    }

    return [
      Opacity(
        opacity: _appBarAnimation.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _appBarAnimation.value) * -20),
          child: ActionButton(
            icon: Icons.add,
            iconColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: _showAddDialog,
          ),
        ),
      ),
      SizedBox(width: 6.w),
    ];
  }

  Widget _buildTabBar(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: PlanningTabBarDelegate(
        tabController: _tabController,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        labelColor: Theme.of(context).textTheme.bodyLarge?.color,
        unselectedLabelColor: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.color
            ?.withValues(alpha: 0.7),
        indicatorColor: Theme.of(context).primaryColor,
        tabLabels: _tabLabels,
      ),
    );
  }
}
