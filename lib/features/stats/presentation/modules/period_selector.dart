import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:table_calendar/table_calendar.dart';

enum PeriodType {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

class PeriodSelector extends StatefulWidget {
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final Function(DateTime startDate, DateTime endDate) onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onPeriodChanged,
  });

  @override
  State<PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  PeriodType _selectedPeriod = PeriodType.thisMonth;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _selectedPeriod =
        _determinePeriodType(widget.selectedStartDate, widget.selectedEndDate);
  }

  PeriodType _determinePeriodType(DateTime start, DateTime end) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if it's today
    if (start.year == today.year &&
        start.month == today.month &&
        start.day == today.day &&
        end.year == today.year &&
        end.month == today.month &&
        end.day == today.day) {
      return PeriodType.today;
    }

    // Check if it's this week
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    if (start.year == weekStart.year &&
        start.month == weekStart.month &&
        start.day == weekStart.day) {
      return PeriodType.thisWeek;
    }

    // Check if it's this month
    final monthStart = DateTime(now.year, now.month, 1);
    if (start.year == monthStart.year &&
        start.month == monthStart.month &&
        start.day == monthStart.day) {
      return PeriodType.thisMonth;
    }

    // Check if it's this year
    final yearStart = DateTime(now.year, 1, 1);
    if (start.year == yearStart.year &&
        start.month == yearStart.month &&
        start.day == yearStart.day) {
      return PeriodType.thisYear;
    }

    return PeriodType.custom;
  }

  void _selectPeriod(PeriodType type) {
    setState(() {
      _selectedPeriod = type;
    });

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (type) {
      case PeriodType.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case PeriodType.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case PeriodType.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case PeriodType.thisYear:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case PeriodType.custom:
        _showCustomDatePicker();
        return;
    }

    widget.onPeriodChanged(startDate, endDate);
  }

  void _showCustomDatePicker() {
    showDialog(
      context: context,
      builder: (context) => _CustomDateRangeDialog(
        initialStartDate: _customStartDate ?? widget.selectedStartDate,
        initialEndDate: _customEndDate ?? widget.selectedEndDate,
        onConfirm: (start, end) {
          setState(() {
            _customStartDate = start;
            _customEndDate = end;
          });
          widget.onPeriodChanged(start, end);
        },
      ),
    );
  }

  String _getPeriodLabel() {
    if (_selectedPeriod == PeriodType.custom &&
        _customStartDate != null &&
        _customEndDate != null) {
      final format = DateFormat('d MMM', 'fr_FR');
      return '${format.format(_customStartDate!)} - ${format.format(_customEndDate!)}';
    }

    switch (_selectedPeriod) {
      case PeriodType.today:
        return "Aujourd'hui";
      case PeriodType.thisWeek:
        return 'Cette semaine';
      case PeriodType.thisMonth:
        return 'Ce mois';
      case PeriodType.thisYear:
        return 'Cette année';
      case PeriodType.custom:
        return 'Période personnalisée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceDim = Theme.of(context).colorScheme.surface;

    return Card(
      color: surfaceDim,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Période',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor?.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: [
                _buildPeriodChip("Aujourd'hui", PeriodType.today),
                _buildPeriodChip('Semaine', PeriodType.thisWeek),
                _buildPeriodChip('Mois', PeriodType.thisMonth),
                _buildPeriodChip('Année', PeriodType.thisYear),
                _buildPeriodChip('Personnalisée', PeriodType.custom),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16.sp,
                    color: AppTheme.primaryGreen,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _getPeriodLabel(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, PeriodType type) {
    final isSelected = _selectedPeriod == type;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return GestureDetector(
      onTap: () => _selectPeriod(type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryGreen
                : textColor!.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
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
                      borderRadius: BorderRadius.circular(3.w),
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
