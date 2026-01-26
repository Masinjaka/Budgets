import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';

class MonthYearPickerDialog extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const MonthYearPickerDialog({super.key, required this.initialDate});

  @override
  ConsumerState<MonthYearPickerDialog> createState() =>
      _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends ConsumerState<MonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  final DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  bool _isMonthDisabled(int month) {
    return _selectedYear == _now.year && month > _now.month;
  }

  bool _canGoToNextYear() {
    return _selectedYear < _now.year;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return AlertDialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.all(4.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Year Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 18.sp, color: textColor),
                onPressed: () {
                  setState(() {
                    _selectedYear--;
                  });
                },
              ),
              Text(
                _selectedYear.toString(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios,
                    size: 18.sp,
                    color: _canGoToNextYear()
                        ? textColor
                        : textColor?.withValues(alpha: 0.3)),
                onPressed: _canGoToNextYear()
                    ? () {
                        setState(() {
                          _selectedYear++;
                        });
                      }
                    : null,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Month Grid - Using Wrap instead of GridView to avoid intrinsic dimension issues
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(12, (index) {
              final month = index + 1;
              final monthNameRaw = DateFormat('MMMM', 'fr')
                  .format(DateTime(_selectedYear, month));
              final monthName =
                  monthNameRaw[0].toUpperCase() + monthNameRaw.substring(1);
              final isSelected = month == _selectedMonth;
              final isDisabled = _isMonthDisabled(month);

              return GestureDetector(
                onTap: isDisabled
                    ? null
                    : () {
                        setState(() {
                          _selectedMonth = month;
                        });
                      },
                child: Container(
                  width: 22.w,
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected && !isDisabled
                        ? primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    monthName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDisabled
                          ? textColor?.withValues(alpha: 0.3)
                          : isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    .animate(key: ValueKey('$month-$isSelected'))
                    .scaleX(
                      begin: isSelected ? 0.95 : 1.0,
                      end: 1.0,
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    ),
              );
            }),
          ),
          SizedBox(height: 2.h),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: textColor?.withValues(alpha: 0.7),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(DateTime(_selectedYear, _selectedMonth, 1));
                },
                child: Text(
                  'Confirmer',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
