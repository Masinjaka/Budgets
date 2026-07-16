import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ResumeDateCalendar extends StatefulWidget {
  const ResumeDateCalendar({
    required this.today,
    required this.selectedDay,
    required this.onDaySelected,
    super.key,
  });

  final DateTime today;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  State<ResumeDateCalendar> createState() => _ResumeDateCalendarState();
}

class _ResumeDateCalendarState extends State<ResumeDateCalendar> {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
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
  }

  void _changeYear(int? year) {
    if (year == null) return;
    final latestMonth = year == _today.year ? _today.month : 12;
    final month = _focusedDay.month.clamp(1, latestMonth);
    setState(() {
      _focusedDay = DateTime(year, month);
    });
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
    final availableMonthCount =
        _focusedDay.year == _today.year ? _today.month : 12;
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
          SizedBox(
            height: 28,
            child: Row(
              children: [
                _dropdown(
                  key: const Key('calendar-month-picker'),
                  value: _focusedDay.month,
                  items: [
                    for (var month = 1; month <= availableMonthCount; month++)
                      DropdownMenuItem(
                        value: month,
                        child: Text(_months[month - 1]),
                      ),
                  ],
                  onChanged: _changeMonth,
                ),
                const SizedBox(width: 18),
                _dropdown(
                  key: const Key('calendar-year-picker'),
                  value: _focusedDay.year,
                  items: [
                    for (final year in years)
                      DropdownMenuItem(value: year, child: Text('$year')),
                  ],
                  onChanged: _changeYear,
                ),
              ],
            ),
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
            onPageChanged: (day) => setState(() => _focusedDay = day),
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
              selectedTextStyle: TextStyle(color: Colors.white, fontSize: 12.5),
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

  Widget _dropdown({
    required Key key,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        key: key,
        value: value,
        items: items,
        onChanged: onChanged,
        isDense: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
