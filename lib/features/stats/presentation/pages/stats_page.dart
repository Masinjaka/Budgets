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

class _StatsPageState extends ConsumerState<StatsPage> {
  late PageController _pageController;
  static const int _initialPage = 1; // Start at middle page (current month)
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
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
      body: Column(
        children: [
          // App bar section
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 1.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rapports',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
          // Month picker
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: MonthYearPicker(
              onPreviousMonth: _goToPreviousMonth,
              onNextMonth: _goToNextMonth,
              onDateSelected: _onDateSelected,
            ),
          ),
          // PageView for stats content
          Expanded(
            child: PageView.builder(
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
        ],
      ),
    );
  }
}
