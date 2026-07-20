import 'package:flutter/material.dart';

class CalendarPeriodPicker extends StatelessWidget {
  const CalendarPeriodPicker({
    required this.focusedDay,
    required this.today,
    required this.years,
    required this.onMonthChanged,
    required this.onYearChanged,
    super.key,
  });

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

  final DateTime focusedDay;
  final DateTime today;
  final List<int> years;
  final ValueChanged<int?> onMonthChanged;
  final ValueChanged<int?> onYearChanged;

  @override
  Widget build(BuildContext context) {
    final monthCount = focusedDay.year == today.year ? today.month : 12;
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          _dropdown(
            key: const Key('calendar-month-picker'),
            value: focusedDay.month,
            items: [
              for (var month = 1; month <= monthCount; month++)
                DropdownMenuItem(
                  value: month,
                  child: Text(_months[month - 1]),
                ),
            ],
            onChanged: onMonthChanged,
          ),
          const SizedBox(width: 18),
          _dropdown(
            key: const Key('calendar-year-picker'),
            value: focusedDay.year,
            items: [
              for (final year in years)
                DropdownMenuItem(value: year, child: Text('$year')),
            ],
            onChanged: onYearChanged,
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
