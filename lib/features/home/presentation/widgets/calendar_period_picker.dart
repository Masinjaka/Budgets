import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';

class CalendarPeriodPicker extends StatelessWidget {
  const CalendarPeriodPicker({
    required this.focusedDay,
    required this.onTap,
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 28,
        child: InkWell(
          key: const Key('calendar-period-picker'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_months[focusedDay.month - 1]} ${focusedDay.year}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontSize: AppTypography.body,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).colorScheme.inverseSurface,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
