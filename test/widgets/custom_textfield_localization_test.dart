import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows password validation in English', (tester) async {
    await _pumpField(tester, const Locale('en'));

    expect(find.text('Enter a password'), findsOneWidget);
  });

  testWidgets('shows password validation in French', (tester) async {
    await _pumpField(tester, const Locale('fr'));

    expect(find.text('Saisissez un mot de passe'), findsOneWidget);
  });
}

Future<void> _pumpField(WidgetTester tester, Locale locale) async {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CustomTextField(
              title: const Text('Password'),
              controller: controller,
              validator: const {'type': 'password'},
            ),
          ),
        ),
      ),
    ),
  );
  formKey.currentState!.validate();
  await tester.pump();
}
