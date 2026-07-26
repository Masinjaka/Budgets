import 'package:budgets/features/home/presentation/widgets/drawer_menu_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Feedback drawer item invokes its callback', (tester) async {
    var feedbackTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DrawerMenuSection(
            onEnvelopePressed: () {},
            onStatsPressed: () {},
            onPlanPressed: () {},
            onFeedbackPressed: () => feedbackTaps++,
          ),
        ),
      ),
    );

    expect(find.text('Feedback'), findsOneWidget);
    await tester.tap(find.byKey(const Key('drawer-feedback-button')));

    expect(feedbackTaps, 1);
  });
}
