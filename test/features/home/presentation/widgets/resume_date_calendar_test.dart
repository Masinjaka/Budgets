import 'package:budgets/core/theme.dart';
import 'package:budgets/features/home/presentation/widgets/resume_date_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  testWidgets('starts on the current week and expands to the month',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ResumeDateCalendar(
            today: DateTime(2026, 7, 16),
            selectedDay: DateTime(2026, 7, 1),
            activityDates: const {},
            onDaySelected: (_) {},
            onVisibleMonthChanged: (_) {},
          ),
        ),
      ),
    );

    var calendar = tester.widget<TableCalendar<void>>(
      find.byType(TableCalendar<void>),
    );
    final collapsedHeight = tester
        .getSize(find.byKey(const Key('resume-date-calendar-card')))
        .height;
    expect(calendar.calendarFormat, CalendarFormat.week);
    expect(isSameDay(calendar.focusedDay, DateTime(2026, 7, 16)), isTrue);

    await tester.tap(find.byKey(const Key('calendar-view-toggle')));
    await tester.pumpAndSettle();

    calendar = tester.widget<TableCalendar<void>>(
      find.byType(TableCalendar<void>),
    );
    final expandedHeight = tester
        .getSize(find.byKey(const Key('resume-date-calendar-card')))
        .height;
    expect(calendar.calendarFormat, CalendarFormat.month);
    expect(expandedHeight, greaterThan(collapsedHeight));
  });

  testWidgets('allows past dates and prevents future date selection',
      (tester) async {
    DateTime? selectedDate;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ResumeDateCalendar(
            today: DateTime(2026, 7, 16),
            selectedDay: DateTime(2026, 7, 16),
            activityDates: const {},
            onDaySelected: (date) => selectedDate = date,
            onVisibleMonthChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('17'));
    await tester.pump();
    expect(selectedDate, isNull);

    await tester.tap(find.text('15'));
    await tester.pump();
    expect(selectedDate, DateTime(2026, 7, 15));
  });

  testWidgets('month and year use one label and the shared bottom sheet',
      (tester) async {
    DateTime? visibleMonth;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ResumeDateCalendar(
            today: DateTime(2026, 7, 16),
            selectedDay: DateTime(2026, 7, 16),
            activityDates: const {},
            onDaySelected: (_) {},
            onVisibleMonthChanged: (date) => visibleMonth = date,
          ),
        ),
      ),
    );

    expect(find.text('July 2026'), findsOneWidget);
    expect(find.byType(DropdownButton<int>), findsNothing);

    await tester.tap(find.byKey(const Key('calendar-period-picker')));
    await tester.pumpAndSettle();
    expect(find.text('Select month and year'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-wheel-picker-done')));
    await tester.pumpAndSettle();
    expect(visibleMonth?.year, 2026);
    expect(visibleMonth?.month, 7);
  });

  testWidgets('marks activity dates with the shared app green', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ResumeDateCalendar(
            today: DateTime(2026, 7, 16),
            selectedDay: DateTime(2026, 7, 16),
            activityDates: {DateTime(2026, 7, 15)},
            onDaySelected: (_) {},
            onVisibleMonthChanged: (_) {},
          ),
        ),
      ),
    );

    final activityDay = tester.widget<Container>(
      find.byKey(const Key('calendar-activity-day-2026-7-15')),
    );
    final decoration = activityDay.decoration as BoxDecoration;
    final activityLabel = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('calendar-activity-day-2026-7-15')),
        matching: find.text('15'),
      ),
    );
    final selectedLabel = tester.widget<Text>(find.text('16'));
    final calendar = tester.widget<TableCalendar<void>>(
      find.byType(TableCalendar<void>),
    );
    final selectedDecoration =
        calendar.calendarStyle.selectedDecoration as BoxDecoration;

    expect(decoration.color, AppTheme.primaryGreen);
    expect(decoration.shape, BoxShape.circle);
    expect(activityLabel.style?.color, AppTheme.interactiveTextColor);
    expect(activityLabel.style?.fontWeight, FontWeight.w700);
    expect(selectedLabel.style?.color, AppTheme.interactiveTextColor);
    expect(selectedLabel.style?.fontWeight, FontWeight.w700);
    expect(selectedDecoration.color, Colors.transparent);
    expect(selectedDecoration.border?.top.color, Colors.black);
  });

  testWidgets('selected activity date uses only the black outline',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ResumeDateCalendar(
            today: DateTime(2026, 7, 16),
            selectedDay: DateTime(2026, 7, 16),
            activityDates: {DateTime(2026, 7, 16)},
            onDaySelected: (_) {},
            onVisibleMonthChanged: (_) {},
          ),
        ),
      ),
    );

    final selectedDay = tester.widget<Container>(
      find.byKey(const Key('calendar-activity-day-2026-7-16')),
    );
    final decoration = selectedDay.decoration as BoxDecoration;

    expect(decoration.color, Colors.transparent);
    expect(decoration.border?.top.color, Colors.black);
    expect(decoration.shape, BoxShape.circle);
  });
}
