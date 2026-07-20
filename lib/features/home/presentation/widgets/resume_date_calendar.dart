import 'package:budgets/core/theme.dart';
import 'package:budgets/features/home/presentation/widgets/activity_calendar_day.dart';
import 'package:budgets/features/home/presentation/widgets/calendar_period_picker.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ResumeDateCalendar extends StatefulWidget {
  const ResumeDateCalendar({
    required this.today,
    required this.selectedDay,
    required this.activityDates,
    required this.onDaySelected,
    required this.onVisibleMonthChanged,
    super.key,
  });

  final DateTime today;
  final DateTime selectedDay;
  final Set<DateTime> activityDates;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onVisibleMonthChanged;

  @override
  State<ResumeDateCalendar> createState() => _ResumeDateCalendarState();
}

class _ResumeDateCalendarState extends State<ResumeDateCalendar> {
  static const _firstYear = 2000;

  late DateTime _focusedDay;
  late DateTime _selectedDay;

  DateTime get _today => DateUtils.dateOnly(widget.today);

  @override
  void initState() {
    super.initState();
    _selectedDay = DateUtils.dateOnly(widget.selectedDay);
    _focusedDay = _selectedDay;
  }

  void _changeMonth(int? month) {
    if (month == null) return;
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, month);
    });
    widget.onVisibleMonthChanged(_focusedDay);
  }

  void _changeYear(int? year) {
    if (year == null) return;
    final latestMonth = year == _today.year ? _today.month : 12;
    final month = _focusedDay.month.clamp(1, latestMonth);
    setState(() {
      _focusedDay = DateTime(year, month);
    });
    widget.onVisibleMonthChanged(_focusedDay);
  }

  void _selectDay(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = DateUtils.dateOnly(selectedDay);
      _focusedDay = focusedDay;
    });
    widget.onDaySelected(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    final years = [
      for (var year = _today.year; year >= _firstYear; year--) year,
    ];

    return Container(
      height: 290,
      margin: const EdgeInsets.only(left: 22, right: 14),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CalendarPeriodPicker(
            focusedDay: _focusedDay,
            today: _today,
            years: years,
            onMonthChanged: _changeMonth,
            onYearChanged: _changeYear,
          ),
          const SizedBox(height: 11),
          TableCalendar<void>(
            key: ValueKey('${_focusedDay.year}-${_focusedDay.month}'),
            firstDay: DateTime(_firstYear),
            lastDay: _today,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            enabledDayPredicate: (day) =>
                !DateUtils.dateOnly(day).isAfter(_today),
            onDaySelected: _selectDay,
            onPageChanged: (day) {
              setState(() => _focusedDay = day);
              widget.onVisibleMonthChanged(day);
            },
            calendarBuilders: CalendarBuilders(
              prioritizedBuilder: (_, day, focusedDay) {
                if (day.month != focusedDay.month) return null;
                return _activityDay(
                  day,
                  isSelected: isSameDay(day, _selectedDay),
                );
              },
            ),
            headerVisible: false,
            daysOfWeekHeight: 25,
            rowHeight: 36,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: TextStyle(fontSize: 12.5),
              weekendTextStyle: TextStyle(fontSize: 12.5),
              disabledTextStyle: TextStyle(
                color: Color(0xFFC5C5C5),
                fontSize: 12.5,
              ),
              selectedTextStyle: TextStyle(
                color: AppTheme.interactiveTextColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF087AC1),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(shape: BoxShape.circle),
              todayTextStyle: TextStyle(color: Colors.black, fontSize: 12.5),
              cellMargin: EdgeInsets.all(1),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Color(0xFF777777), fontSize: 10.5),
              weekendStyle: TextStyle(color: Color(0xFF777777), fontSize: 10.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _activityDay(DateTime day, {bool isSelected = false}) {
    if (!widget.activityDates.contains(DateUtils.dateOnly(day))) return null;
    return ActivityCalendarDay(
      day: day,
      isSelected: isSelected,
    );
  }
}
