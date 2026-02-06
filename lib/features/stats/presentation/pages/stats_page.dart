import 'package:budgets/features/stats/domain/providers/selected_date_provider.dart';
import 'package:budgets/features/stats/presentation/widgets/month_year_picker.dart';
import 'package:budgets/features/stats/presentation/widgets/stats_page_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _appBarAnimationController;
  late Animation<double> _appBarAnimation;
  static const int _initialPage = 1; // Start at middle page (current month)
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
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

  @override
  void dispose() {
    _pageController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  DateTime _getMonthForPage(DateTime selectedDate, int pageIndex) {
    // pageIndex 0 = previous month, 1 = current month, 2 = next month
    final offset = pageIndex - _initialPage;
    return DateTime(selectedDate.year, selectedDate.month + offset, 1);
  }

  bool _canGoToNextMonth(DateTime selectedDate) {
    final now = DateTime.now();
    return selectedDate.year < now.year ||
        (selectedDate.year == now.year && selectedDate.month < now.month);
  }

  void _goToPreviousMonth() {
    if (_isAnimating) return;
    _isAnimating = true;
    _pageController
        .animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    )
        .then((_) {
      ref.read(selectedDateProvider.notifier).previousMonth();
      // Reset to middle page without animation
      _pageController.jumpToPage(_initialPage);
      _isAnimating = false;
    });
  }

  void _goToNextMonth() {
    final selectedDate = ref.read(selectedDateProvider);
    if (_isAnimating || !_canGoToNextMonth(selectedDate)) return;
    _isAnimating = true;
    _pageController
        .animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    )
        .then((_) {
      ref.read(selectedDateProvider.notifier).nextMonth();
      // Reset to middle page without animation
      _pageController.jumpToPage(_initialPage);
      _isAnimating = false;
    });
  }

  void _onDateSelected(DateTime newDate) {
    ref.read(selectedDateProvider.notifier).setDate(newDate);
    // Page is already at center, just update the provider
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      extendBodyBehindAppBar: false,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
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
                              'Rapports',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                                color: textColor?.withValues(
                                    alpha:
                                        _appBarAnimation.value > 0.1 ? 1 : 0),
                              ),
                            ),
                          ),
                        )
                      : null,
                  centerTitle: false,
                );
              },
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _DatePickerHeaderDelegate(
                height: 5.h + 4.h,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: MonthYearPicker(
                  onPreviousMonth: _goToPreviousMonth,
                  onNextMonth: _goToNextMonth,
                  onDateSelected: _onDateSelected,
                ),
              ),
            ),
          ];
        },
        body: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            final monthDate = _getMonthForPage(selectedDate, index);
            return StatsPageContent(
              key: ValueKey('${monthDate.year}-${monthDate.month}'),
              date: monthDate,
            );
          },
        ),
      ),
    );
  }
}

class _DatePickerHeaderDelegate extends SliverPersistentHeaderDelegate {
  _DatePickerHeaderDelegate({
    required this.height,
    required this.backgroundColor,
    required this.child,
  });

  final double height;
  final Color backgroundColor;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 0.h),
        child: Center(
          child: SizedBox(
            width: 90.w,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DatePickerHeaderDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.child != child;
  }
}
