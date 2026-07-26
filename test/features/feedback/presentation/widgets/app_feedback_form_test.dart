import 'package:budgets/features/feedback/presentation/widgets/app_feedback_form.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses shared form controls and submits feedback', (tester) async {
    String? submittedFeedback;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppFeedbackForm(
              scrollController: null,
              onSubmit: (feedback, {extras}) async {
                submittedFeedback = feedback;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CustomTextField), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'A useful idea');
    await tester.tap(find.byKey(const Key('feedback-submit-button')));
    await tester.pump();

    expect(submittedFeedback, 'A useful idea');
  });

  testWidgets('shows the custom feedback form in French', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppFeedbackForm(
              scrollController: null,
              onSubmit: (feedback, {extras}) async {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dites-nous ce que vous en pensez'), findsOneWidget);
    expect(find.text('Envoyer l’avis'), findsOneWidget);
  });

}
