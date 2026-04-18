import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/categories/presentation/widgets/category_tab_bar_delegate.dart';
import 'package:budgets/features/categories/presentation/widgets/category_tab_content.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage>
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
              // SliverAppBar for categories page
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
                    titleSpacing: 8.w,
                    title: _appBarAnimation.value > 0.1
                        ? Opacity(
                            opacity: _appBarAnimation.value,
                            child: Transform.translate(
                              offset:
                                  Offset(0, (1 - _appBarAnimation.value) * -20),
                              child: Text(
                                'Catégories',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withValues(
                                        alpha: _appBarAnimation.value > 0.1
                                            ? 1
                                            : 0,
                                      ),
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
                                child: CustomButton.icon(
                                  icon: Icons.add,
                                  iconColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  width: 4.5.h,
                                  height: 4.5.h,
                                  onPressed: () {
                                    // Get the current active tab to determine transaction type
                                    final isExpenseTab =
                                        _tabController.index == 0;
                                    final transactionType =
                                        isExpenseTab ? 'expense' : 'income';
                                    context.push(
                                        "/add-category?type=$transactionType");
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ]
                        : [],
                  );
                },
              ),
              // Tab view positioned at top left - pinned to not scroll with content
              SliverPersistentHeader(
                pinned: true,
                delegate: CategoryTabBarDelegate(
                  tabController: _tabController,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                  unselectedLabelColor: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withValues(alpha: 0.7),
                  indicatorColor: Theme.of(context).primaryColor,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: const [
              // Expense categories tab
              CategoryTabContent(
                transactionType: TransactionType.expense,
              ),
              // Income categories tab
              CategoryTabContent(
                transactionType: TransactionType.income,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
