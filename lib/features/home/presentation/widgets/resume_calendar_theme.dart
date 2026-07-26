import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ResumeCalendarTheme {
  const ResumeCalendarTheme._();

  static CalendarStyle calendar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final interactive = colors.inverseSurface;
    return CalendarStyle(
      outsideDaysVisible: false,
      defaultTextStyle: TextStyle(
        color: colors.onSurface,
        fontSize: AppTypography.supporting,
      ),
      weekendTextStyle: TextStyle(
        color: colors.onSurface,
        fontSize: AppTypography.supporting,
      ),
      disabledTextStyle: TextStyle(
        color: colors.onSurface.withValues(alpha: .28),
        fontSize: AppTypography.supporting,
      ),
      selectedTextStyle: TextStyle(
        color: interactive,
        fontSize: AppTypography.supporting,
        fontWeight: FontWeight.w700,
      ),
      selectedDecoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: interactive, width: 1.2),
      ),
      todayDecoration: const BoxDecoration(shape: BoxShape.circle),
      todayTextStyle: TextStyle(
        color: interactive,
        fontSize: AppTypography.supporting,
      ),
      cellMargin: const EdgeInsets.all(1),
    );
  }

  static DaysOfWeekStyle daysOfWeek(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: .55);
    return DaysOfWeekStyle(
      weekdayStyle: TextStyle(
        color: color,
        fontSize: AppTypography.caption,
      ),
      weekendStyle: TextStyle(
        color: color,
        fontSize: AppTypography.caption,
      ),
    );
  }
}
