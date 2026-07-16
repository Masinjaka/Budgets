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
            onDaySelected: (date) => selectedDate = date,
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
            onDaySelected: (_) {},
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
}
