import 'package:budgets/features/stats/domain/providers/selected_date_provider.dart';
import 'package:budgets/features/stats/presentation/widgets/month_year_picker_dialog.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';

class MonthYearPicker extends ConsumerWidget {
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final void Function(DateTime)? onDateSelected;

  const MonthYearPicker({
    super.key,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final tabIndicatorColor = Theme.of(context).tabBarTheme.indicatorColor;
    final tabLabelColor = Theme.of(context).tabBarTheme.labelColor;
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();

    final formatted = DateFormat('MMMM yyyy', 'fr').format(selectedDate);
    final formattedMonthYear =
        formatted[0].toUpperCase() + formatted.substring(1);

    // Check if we can go to next month (not beyond current month/year)
    final canGoToNextMonth = selectedDate.year < now.year ||
        (selectedDate.year == now.year && selectedDate.month < now.month);

    return Container(
      height: 5.5.h,
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 8.w, height: 5.h),
            icon: Icon(Icons.arrow_back_ios, size: 16.sp, color: textColor),
            onPressed: () {
              if (onPreviousMonth != null) {
                onPreviousMonth!();
              } else {
                ref.read(selectedDateProvider.notifier).previousMonth();
              }
            },
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final newDate = await showAnimatedDialog<DateTime>(
                context: context,
                builder: (BuildContext context) {
                  return MonthYearPickerDialog(initialDate: selectedDate);
                },
              );
              if (newDate != null) {
                if (onDateSelected != null) {
                  onDateSelected!(newDate);
                } else {
                  ref.read(selectedDateProvider.notifier).setDate(newDate);
                }
              }
            },
            child: Container(
              height: 5.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: tabIndicatorColor,
                borderRadius: BorderRadius.circular(100),
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  formattedMonthYear,
                  key: ValueKey(formattedMonthYear),
                  style: TextStyle(
                    color: tabLabelColor,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate(key: ValueKey(formattedMonthYear)).scaleX(
                begin: 0.95, end: 1.0, duration: 200.ms, curve: Curves.easeOut),
          ),
          const Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 8.w, height: 5.h),
            icon: Icon(Icons.arrow_forward_ios,
                size: 16.sp,
                color: canGoToNextMonth
                    ? textColor
                    : textColor?.withValues(alpha: 0.3)),
            onPressed: canGoToNextMonth
                ? () {
                    if (onNextMonth != null) {
                      onNextMonth!();
                    } else {
                      ref.read(selectedDateProvider.notifier).nextMonth();
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
