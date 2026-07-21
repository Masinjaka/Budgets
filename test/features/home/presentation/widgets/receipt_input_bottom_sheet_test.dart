import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/home_test_window.dart';

void main() {
  testWidgets('plus opens receipt options without the adjustment control',
      (tester) async {
    usePhoneWindow(tester);
    await tester.pumpWidget(
      MaterialApp(home: ChatHomePage(today: DateTime(2026, 7, 16))),
    );

    expect(find.byTooltip('Input options'), findsNothing);

    await tester.tap(find.byTooltip('Add receipt'));
    await tester.pumpAndSettle();

    expect(find.text('Import file'), findsOneWidget);
    expect(find.text('Scan receipt'), findsOneWidget);
    expect(find.text('Enter manually'), findsOneWidget);
    expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);
    expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
    expect(find.byIcon(Icons.document_scanner_outlined), findsOneWidget);
  });
}
