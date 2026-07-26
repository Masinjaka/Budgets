import 'package:budgets/features/home/presentation/widgets/chat_input_bar.dart';
import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:budgets/features/home/presentation/services/receipt_input_service.dart';
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

    expect(find.text('Expense, income, or transfer'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    final sendIcon = tester.widget<Icon>(
      find.byIcon(Icons.arrow_upward_rounded),
    );
    expect(sendIcon.color, Colors.black);
    final sendCircle = tester.widget<CircleAvatar>(
      find.ancestor(
        of: find.byIcon(Icons.arrow_upward_rounded),
        matching: find.byType(CircleAvatar),
      ),
    );
    expect(sendCircle.backgroundColor, const Color(0xFF10B981));

    await tester.enterText(
      find.byType(TextField),
      'I spent 24 000 Ar on lunch',
    );
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    expect(submitted, 'I spent 24 000 Ar on lunch');
    expect(find.text('I spent 24 000 Ar on lunch'), findsNothing);
  });

  testWidgets('grows the composer for multiline input', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            isSubmitting: false,
            onManualEntryRequested: () async {},
            onSubmit: (_) async => true,
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 4);
    expect(field.textInputAction, TextInputAction.newline);
    final initialHeight = tester
        .getSize(
          find.byKey(const Key('chat-input-container')),
        )
        .height;

    await tester.enterText(
      find.byType(TextField),
      'First line\nSecond line\nThird line',
    );
    await tester.pumpAndSettle();

    final multilineHeight = tester
        .getSize(
          find.byKey(const Key('chat-input-container')),
        )
        .height;
    expect(multilineHeight, greaterThan(initialHeight));
    expect(multilineHeight, lessThanOrEqualTo(110));
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
    await tester.pumpAndSettle();
    final focusNode =
        tester.widget<EditableText>(find.byType(EditableText)).focusNode;
    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

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

  testWidgets('scanned receipt is sent for AI processing', (tester) async {
    ReceiptInputResult? submitted;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            isSubmitting: false,
            receiptInputService: _FakeReceiptInputService(),
            onSubmit: (_) async => true,
            onManualEntryRequested: () async {},
            onReceiptSubmit: (input) async {
              submitted = input;
              return true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Add receipt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan receipt'));
    await tester.pumpAndSettle();

    expect(submitted?.paths, ['/tmp/receipt.jpg']);
    expect(submitted?.source, ReceiptInputSource.scannedReceipt);
  });
}

class _FakeReceiptInputService extends ReceiptInputService {
  @override
  Future<ReceiptInputResult?> scanReceipt() async => const ReceiptInputResult(
        source: ReceiptInputSource.scannedReceipt,
        paths: ['/tmp/receipt.jpg'],
      );
}
