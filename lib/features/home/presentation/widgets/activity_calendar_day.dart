import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/app_typography.dart';
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
        color: isSelected ? Colors.transparent : AppTheme.primaryGreen,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.inverseSurface,
                width: 1.2,
              )
            : null,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.inverseSurface
              : Theme.of(context).colorScheme.onPrimary,
          fontSize: AppTypography.supporting,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
