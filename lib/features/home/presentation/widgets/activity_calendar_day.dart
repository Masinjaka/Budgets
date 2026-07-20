import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';

class ActivityCalendarDay extends StatelessWidget {
  const ActivityCalendarDay({
    required this.day,
    required this.isSelected,
    super.key,
  });

  final DateTime day;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('calendar-activity-day-${day.year}-${day.month}-${day.day}'),
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: AppTheme.secondaryGreen, width: 2)
            : null,
      ),
      child: Text(
        '${day.day}',
        style: const TextStyle(
          color: AppTheme.interactiveTextColor,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
