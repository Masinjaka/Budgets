import 'package:budgets/core/theme.dart';
import 'package:budgets/features/home/presentation/widgets/chat_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows suggestions for an empty focused composer',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              isSubmitting: false,
              onManualEntryRequested: () async {},
              onSubmit: (_) async => true,
            ),
          ),
        ),
      ),
    );

    final reveal = find.byKey(const Key('chat-suggestions-reveal'));
    expect(tester.getSize(reveal).height, 0);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(tester.getSize(reveal).height, greaterThan(0));
    expect(find.text('I spent X on Y today'), findsOneWidget);
    expect(find.text('I received a payment of X'), findsOneWidget);
    expect(
      find.text('Transfer X from wallet A to wallet B'),
      findsOneWidget,
    );

    await tester.tap(find.text('I spent X on Y today'));
    await tester.pumpAndSettle();

    expect(tester.getSize(reveal).height, 0);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'I spent X on Y today',
    );
  });

  testWidgets('uses a black cursor', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ChatInputBar(
            isSubmitting: false,
            onManualEntryRequested: () async {},
            onSubmit: (_) async => true,
          ),
        ),
      ),
    );

    expect(
      tester.widget<TextField>(find.byType(TextField)).cursorColor,
      Colors.black,
    );
  });
}
