import 'package:budgets/core/ui/app_wheel_picker.dart';
import 'package:budgets/features/home/presentation/widgets/activity_calendar_day.dart';
import 'package:budgets/features/home/presentation/widgets/calendar_view_toggle.dart';
import 'package:budgets/features/home/presentation/widgets/calendar_period_picker.dart';
import 'package:budgets/features/home/presentation/widgets/resume_calendar_theme.dart';
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
  bool _isMonthView = false;

  DateTime get _today => DateUtils.dateOnly(widget.today);

  @override
  void initState() {
    super.initState();
    _selectedDay = DateUtils.dateOnly(widget.selectedDay);
    _focusedDay = _today;
  }

  Future<void> _selectPeriod() async {
    final selected = await AppWheelPicker.monthYear(
      context,
      initialDate: _focusedDay,
      firstDate: DateTime(_firstYear),
      lastDate: _today,
      title: 'Select month and year',
    );
    if (selected == null || !mounted) return;
    final focusedDay = DateTime(selected.year, selected.month);
    setState(() => _focusedDay = focusedDay);
    widget.onVisibleMonthChanged(focusedDay);
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
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          key: const Key('resume-date-calendar-card'),
          margin: const EdgeInsets.only(left: 22, right: 14),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              CalendarPeriodPicker(
                focusedDay: _focusedDay,
                onTap: _selectPeriod,
              ),
              const SizedBox(height: 11),
              TableCalendar<void>(
                key: ValueKey('${_focusedDay.year}-${_focusedDay.month}'),
                firstDay: DateTime(_firstYear),
                lastDay: _today,
                focusedDay: _focusedDay,
                calendarFormat:
                    _isMonthView ? CalendarFormat.month : CalendarFormat.week,
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
                calendarStyle: ResumeCalendarTheme.calendar(context),
                daysOfWeekStyle: ResumeCalendarTheme.daysOfWeek(context),
              ),
              CalendarViewToggle(
                isExpanded: _isMonthView,
                onPressed: () => setState(() => _isMonthView = !_isMonthView),
              ),
            ],
          ),
        ),
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
