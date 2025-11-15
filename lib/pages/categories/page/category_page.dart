import 'package:budgets/core/theme.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/model/category_model.dart';
import 'package:budgets/provider/category_provider.dart';
import 'package:budgets/widgets/custom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
                    backgroundColor: AppTheme.backgroundDark,
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
                                'Catégories',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  color: Colors.white.withValues(
                                      alpha: _appBarAnimation.value),
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
                                  icon: Icons.add,
                                  iconColor: AppTheme.secondaryDark,
                                  backgroundColor: AppTheme.primaryGreen,
                                  onPressed: () {
                                    // Get the current active tab to determine transaction type
                                    final isExpenseTab = _tabController.index == 0;
                                    final transactionType = isExpenseTab ? 'expense' : 'income';
                                    context.push("/add-category?type=$transactionType");
                                  },
                                ),
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
                delegate: _CategoryTabBarDelegate(
                  tabController: _tabController,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: const [
              // Expense categories tab
              _CategoryTabContent(
                transactionType: TransactionType.expense,
              ),
              // Income categories tab
              _CategoryTabContent(
                transactionType: TransactionType.income,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate widget for category tab content
class _CategoryTabContent extends ConsumerWidget {
  final TransactionType transactionType;
  
  const _CategoryTabContent({required this.transactionType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: switch (categoriesAsyncValue) {
              AsyncData(:final value) => _categoryGrid(_filterCategories(value)),
              AsyncError(:final error) => Text('error: $error'),
              _ => _skeleton(),
            },
          ),
        ],
      ),
    );
  }

  /// Filter categories by transaction type
  List<Category> _filterCategories(List<Category> categories) {
    return categories.where((category) => 
      category.transactionType == transactionType
    ).toList();
  }

  GridView _skeleton() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: 5,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
        childAspectRatio: 2.0, // This makes the height half of the width
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 119, 119, 119),
          borderRadius: BorderRadius.circular(5.w),
        ),
      ),
    );
  }

  _categoryGrid(List<Category> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'Aucune catégorie trouvée.',
          style: TextStyle(
        color: AppTheme.borderColorDark,
        fontSize: 16.sp,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
        childAspectRatio: 2.0, // This makes the height half of the width
      ),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          context.push('/add-category', extra: categories[index]);
        },
        child: Container(
          decoration: BoxDecoration(
            // color: AppTheme.secondaryDark,
            color: Color(int.parse(categories[index].color!, radix: 16)),
            borderRadius: BorderRadius.circular(5.w),
            border: Border.all(
              color: AppTheme.borderColorDark,
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 2.w,
            children: [
              SizedBox(width: 4.w),
              Text(
                '${categories[index].emoji}',
                style: TextStyle(
                  fontSize: 20.sp,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      offset: const Offset(1, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Text(
                '${categories[index].name}',
                style: TextStyle(
                  fontSize: 15.sp,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      offset: const Offset(1, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(delay: (50 * index).ms)
            .fade(duration: 200.ms)
            .slideY(begin: 0.5, duration: 200.ms, curve: Curves.easeOut),
      ),
    );
  }
}

class _CategoryTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  
  _CategoryTabBarDelegate({required this.tabController});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundDark,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 60.w, // Set a fixed width for the TabBar
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: TabBar(
              controller: tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: AppTheme.primaryGreen,
                  width: 3.0,
                ),
                insets: EdgeInsets.symmetric(horizontal: 4.w),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  child: Text(
                    'Dépenses',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Revenus',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
    return false;
  }
}
