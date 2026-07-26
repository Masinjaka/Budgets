import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/app_control_metrics.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('button and text field share the 45 pixel control height',
      (tester) async {
    await _pumpControls(tester, AppTheme.lightTheme);

    expect(
      tester.getSize(find.byType(ElevatedButton)).height,
      AppControlMetrics.height,
    );
    expect(
      tester.getSize(find.byType(TextFormField)).height,
      AppControlMetrics.height,
    );
    final decorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(decorator.decoration.fillColor, AppTheme.neutralSurface);
  });

  testWidgets('default button colors reverse in dark mode', (tester) async {
    await _pumpControls(tester, AppTheme.lightTheme);
    _expectButtonColors(tester, Colors.black, Colors.white);

    await _pumpControls(tester, AppTheme.darkTheme);
    _expectButtonColors(tester, Colors.white, Colors.black);
  });
}

Future<void> _pumpControls(WidgetTester tester, ThemeData theme) async {
  final controller = TextEditingController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: theme,
        darkTheme: theme,
        themeMode: theme.brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        home: Scaffold(
          body: Column(
            children: [
              CustomTextField(
                title: const Text('Label'),
                controller: controller,
              ),
              CustomButton(text: 'Continue', onPressed: () {}),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectButtonColors(
  WidgetTester tester,
  Color background,
  Color foreground,
) {
  final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
  expect(button.style?.backgroundColor?.resolve({}), background);
  expect(button.style?.foregroundColor?.resolve({}), foreground);
  final label = tester.widget<Text>(find.text('Continue'));
  expect(label.style?.fontWeight, FontWeight.w800);
}
