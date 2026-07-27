import 'package:budgets/core/theme.dart';
import 'package:budgets/features/auth/presentation/widgets/sign_up_password_fields.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reveals live requirements and confirmation progressively',
      (tester) async {
    final passwordController = TextEditingController();
    final confirmationController = TextEditingController();
    addTearDown(passwordController.dispose);
    addTearDown(confirmationController.dispose);

    await tester.pumpWidget(
      _testApp(
        passwordController: passwordController,
        confirmationController: confirmationController,
      ),
    );

    expect(find.byKey(const Key('password-requirements')), findsNothing);
    expect(find.byKey(const Key('confirm-password-field')), findsNothing);

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('password-requirements')), findsOneWidget);
    expect(find.byKey(const Key('confirm-password-field')), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'Abcdef1!');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('confirm-password-field')), findsOneWidget);
    for (final key in _requirementKeys) {
      final semantics = tester.widget<Semantics>(find.byKey(key));
      expect(semantics.properties.checked, isTrue);
    }

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('password-requirements')), findsNothing);
    expect(find.byKey(const Key('confirm-password-field')), findsOneWidget);
  });

  testWidgets('hides confirmation when the password becomes invalid',
      (tester) async {
    final passwordController = TextEditingController(text: 'Abcdef1!');
    final confirmationController = TextEditingController(text: 'Abcdef1!');
    addTearDown(passwordController.dispose);
    addTearDown(confirmationController.dispose);

    await tester.pumpWidget(
      _testApp(
        passwordController: passwordController,
        confirmationController: confirmationController,
      ),
    );
    expect(find.byKey(const Key('confirm-password-field')), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'abcdef1!');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('confirm-password-field')), findsNothing);
    expect(confirmationController.text, isEmpty);
  });
}

const _requirementKeys = [
  Key('password-requirement-length'),
  Key('password-requirement-uppercase'),
  Key('password-requirement-lowercase'),
  Key('password-requirement-number'),
  Key('password-requirement-special'),
];

Widget _testApp({
  required TextEditingController passwordController,
  required TextEditingController confirmationController,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: SignUpPasswordFields(
          passwordController: passwordController,
          confirmPasswordController: confirmationController,
        ),
      ),
    ),
  );
}
