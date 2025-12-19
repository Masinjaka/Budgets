import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:table_calendar/table_calendar.dart';

class PeriodDropdown extends StatefulWidget {
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final Function(DateTime, DateTime) onPeriodChanged;
  final Color? textColor;

  const PeriodDropdown({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onPeriodChanged,
    this.textColor,
  });

  @override
  State<PeriodDropdown> createState() => _PeriodDropdownState();
}

class _PeriodDropdownState extends State<PeriodDropdown> {
  @override
  Widget build(BuildContext context) {
    return _buildPeriodDropdown(widget.textColor);
  }

  Widget _buildPeriodDropdown(Color? textColor) {
    String getPeriodLabel() {
      final format = DateFormat('d MMM yyyy', 'fr_FR');
      if (widget.selectedStartDate.year == widget.selectedEndDate.year &&
          widget.selectedStartDate.month == widget.selectedEndDate.month &&
          widget.selectedStartDate.day == widget.selectedEndDate.day) {
        return format.format(widget.selectedStartDate);
      }
      return '${format.format(widget.selectedStartDate)} - ${format.format(widget.selectedEndDate)}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Période',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Builder(
          builder: (BuildContext buttonContext) {
            return GestureDetector(
              onTap: () => _showPeriodMenu(buttonContext),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getPeriodLabel(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: textColor,
                    size: 18.sp,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showPeriodMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset buttonPosition =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;

    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + buttonSize.height,
        buttonPosition.dx + buttonSize.width,
        buttonPosition.dy + buttonSize.height,
      ),
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.w),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'today',
          child: Row(
            children: [
              Icon(Icons.today, size: 16.sp, color: textColor),
              SizedBox(width: 3.w),
              Text(
                'Aujourd\'hui',
                style: TextStyle(color: textColor, fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'week',
          child: Row(
            children: [
              Icon(Icons.date_range, size: 16.sp, color: textColor),
              SizedBox(width: 3.w),
              Text(
                'Cette semaine',
                style: TextStyle(color: textColor, fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'month',
          child: Row(
            children: [
              Icon(Icons.calendar_month, size: 16.sp, color: textColor),
              SizedBox(width: 3.w),
              Text(
                'Ce mois',
                style: TextStyle(color: textColor, fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'year',
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16.sp, color: textColor),
              SizedBox(width: 3.w),
              Text(
                'Cette année',
                style: TextStyle(color: textColor, fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'custom',
          child: Row(
            children: [
              Icon(Icons.edit_calendar, size: 16.sp, color: textColor),
              SizedBox(width: 3.w),
              Text(
                'Personnalisée',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        _handlePeriodSelection(value);
      }
    });
  }

  void _handlePeriodSelection(String value) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (value) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        widget.onPeriodChanged(startDate, endDate);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        widget.onPeriodChanged(startDate, endDate);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        widget.onPeriodChanged(startDate, endDate);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        widget.onPeriodChanged(startDate, endDate);
        break;
      case 'custom':
        _showCustomDatePicker();
        break;
    }
  }

  void _showCustomDatePicker() {
    showDialog(
      context: context,
      builder: (context) => _CustomDateRangeDialog(
        initialStartDate: widget.selectedStartDate,
        initialEndDate: widget.selectedEndDate,
        onConfirm: (start, end) {
          widget.onPeriodChanged(start, end);
        },
      ),
    );
  }
}

class _CustomDateRangeDialog extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime start, DateTime end) onConfirm;

  const _CustomDateRangeDialog({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onConfirm,
  });

  @override
  State<_CustomDateRangeDialog> createState() => _CustomDateRangeDialogState();
}

class _CustomDateRangeDialogState extends State<_CustomDateRangeDialog> {
  late DateTime _focusedDay;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialStartDate;
    _selectedStartDate = widget.initialStartDate;
    _selectedEndDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sélectionner une période',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 2.h),
            TableCalendar(
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              locale: 'fr_FR',
              rangeStartDay: _selectedStartDate,
              rangeEndDay: _selectedEndDate,
              rangeSelectionMode: _rangeSelectionMode,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor:
                    AppTheme.primaryGreen.withValues(alpha: 0.2),
                withinRangeTextStyle: TextStyle(color: textColor),
                outsideDaysVisible: false,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _selectedStartDate = start ?? _selectedStartDate;
                  _selectedEndDate = end ?? _selectedEndDate;
                  _focusedDay = focusedDay;
                });
              },
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                ElevatedButton(
                  onPressed: () {
                    final start = DateTime(
                      _selectedStartDate.year,
                      _selectedStartDate.month,
                      _selectedStartDate.day,
                    );
                    final end = DateTime(
                      _selectedEndDate.year,
                      _selectedEndDate.month,
                      _selectedEndDate.day,
                      23,
                      59,
                      59,
                    );
                    widget.onConfirm(start, end);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                  ),
                  child: Text(
                    'Confirmer',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
