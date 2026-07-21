import 'package:budgets/features/home/presentation/widgets/ai_request_quota_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the remaining AI request count above the input area',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AiRequestQuotaLabel(remaining: 17),
              TextField(),
            ],
          ),
        ),
      ),
    );

    expect(
      find.text('You have 17 AI requests remaining today', findRichText: true),
      findsOneWidget,
    );
    final label = tester.widget<Text>(
      find.byKey(const Key('ai-request-quota-label')),
    );
    final span = label.textSpan! as TextSpan;
    expect((span.children![1] as TextSpan).style?.fontWeight, FontWeight.w600);
  });

  testWidgets('reserves its space while the quota is loading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [AiRequestQuotaLabel(remaining: null)],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('ai-request-quota-label')), findsNothing);
    expect(tester.getSize(find.byType(AiRequestQuotaLabel)).height, 24);
  });

  testWidgets('shows unlimited usage for a Drala Plus account', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AiRequestQuotaLabel(remaining: null, unlimited: true),
        ),
      ),
    );

    expect(
      find.text('Unlimited AI requests with Drala Plus'),
      findsOneWidget,
    );
  });
}
