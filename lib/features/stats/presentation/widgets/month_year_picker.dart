import 'package:budgets/features/stats/domain/providers/selected_date_provider.dart';
import 'package:budgets/features/stats/presentation/widgets/month_year_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';

class MonthYearPicker extends ConsumerWidget {
  const MonthYearPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final selectedDate = ref.watch(selectedDateProvider);

    String formattedMonthYear =
        DateFormat('MMMM yyyy', 'fr').format(selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18.sp, color: textColor),
          onPressed: () {
            ref.read(selectedDateProvider.notifier).previousMonth();
          },
        ),
        GestureDetector(
          onTap: () async {
            final newDate = await showDialog<DateTime>(
              context: context,
              builder: (BuildContext context) {
                return MonthYearPickerDialog(initialDate: selectedDate);
              },
            );
            if (newDate != null) {
              ref.read(selectedDateProvider.notifier).setDate(newDate);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              formattedMonthYear,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios, size: 18.sp, color: textColor),
          onPressed: () {
            ref.read(selectedDateProvider.notifier).nextMonth();
          },
        ),
      ],
    );
  }
}
