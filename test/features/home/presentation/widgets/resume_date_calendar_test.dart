import 'package:budgets/core/theme.dart';
import 'package:budgets/features/home/presentation/widgets/resume_date_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('allows past dates and prevents future date selection',
      (tester) async {
    DateTime? selectedDate;
    await tester.pumpWidget(
      MaterialApp(
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

  testWidgets('month and year controls change the displayed period',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResumeDateCalendar(
            today: DateTime(2026, 7, 16),
            selectedDay: DateTime(2026, 7, 16),
            activityDates: const {},
            onDaySelected: (_) {},
            onVisibleMonthChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('calendar-month-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('June').last);
    await tester.pumpAndSettle();

    final monthPicker = tester.widget<DropdownButton<int>>(
      find.byKey(const Key('calendar-month-picker')),
    );
    expect(monthPicker.value, 6);

    await tester.tap(find.byKey(const Key('calendar-year-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2025').last);
    await tester.pumpAndSettle();

    final yearPicker = tester.widget<DropdownButton<int>>(
      find.byKey(const Key('calendar-year-picker')),
    );
    expect(yearPicker.value, 2025);
  });

  testWidgets('marks activity dates with the shared app green', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
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

    expect(decoration.color, AppTheme.primaryGreen);
    expect(decoration.shape, BoxShape.circle);
    expect(activityLabel.style?.color, AppTheme.interactiveTextColor);
    expect(activityLabel.style?.fontWeight, FontWeight.w700);
    expect(selectedLabel.style?.color, AppTheme.interactiveTextColor);
    expect(selectedLabel.style?.fontWeight, FontWeight.w700);
  });
}
