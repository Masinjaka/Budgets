import 'package:budgets/features/stats/domain/providers/selected_date_provider.dart';
import 'package:budgets/features/stats/presentation/widgets/month_year_picker_dialog.dart';
import 'package:flutter/material.dart';
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();

    final formatted = DateFormat('MMMM yyyy', 'fr').format(selectedDate);
    final formattedMonthYear =
        formatted[0].toUpperCase() + formatted.substring(1);

    // Check if we can go to next month (not beyond current month/year)
    final canGoToNextMonth = selectedDate.year < now.year ||
        (selectedDate.year == now.year && selectedDate.month < now.month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18.sp, color: textColor),
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
            final newDate = await showDialog<DateTime>(
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
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              formattedMonthYear,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios,
              size: 18.sp,
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
    );
  }
}
