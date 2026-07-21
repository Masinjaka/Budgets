import 'package:budgets/features/home/presentation/widgets/chat_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('submits natural language and clears after success',
      (tester) async {
    String? submitted;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            isSubmitting: false,
            onManualEntryRequested: () async {},
            onSubmit: (message) async {
              submitted = message;
              return true;
            },
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      'I spent 24 000 Ar on lunch',
    );
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();

    expect(submitted, 'I spent 24 000 Ar on lunch');
    expect(find.text('I spent 24 000 Ar on lunch'), findsNothing);
  });

  testWidgets('unfocuses the chat field when tapping outside', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
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

    await tester.tap(find.byType(TextField));
    await tester.pump();
    final focusNode =
        tester.widget<EditableText>(find.byType(EditableText)).focusNode;
    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump();

    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('manual option invokes manual entry flow', (tester) async {
    var requested = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            isSubmitting: false,
            onSubmit: (_) async => true,
            onManualEntryRequested: () async {
              requested = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Add receipt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enter manually'));
    await tester.pumpAndSettle();

    expect(requested, isTrue);
  });

  testWidgets('quota exhaustion replaces send with manual entry',
      (tester) async {
    var requested = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            isSubmitting: false,
            isQuotaExhausted: true,
            onSubmit: (_) async => true,
            onManualEntryRequested: () async => requested = true,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('manual-entry-send')), findsOneWidget);
    expect(find.byKey(const Key('ai-send')), findsNothing);
    await tester.tap(find.byTooltip('Manual entry'));
    await tester.pump();
    expect(requested, isTrue);
  });
}
