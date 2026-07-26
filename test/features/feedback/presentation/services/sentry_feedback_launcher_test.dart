import 'dart:typed_data';

import 'package:budgets/features/feedback/presentation/services/sentry_feedback_launcher.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the app toast after a successful upload', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (builderContext) {
            context = builderContext;
            return const Scaffold(body: SizedBox.expand());
          },
        ),
      ),
    );

    await SentryFeedbackLauncher.submit(
      context,
      UserFeedback(
        text: 'A useful idea',
        screenshot: Uint8List(0),
      ),
      uploader: (_) async {},
    );
    await tester.pump();

    expect(find.text('Feedback sent. Thank you!'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
  });
}
