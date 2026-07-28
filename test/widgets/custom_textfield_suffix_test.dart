import 'package:budgets/core/theme.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps the trailing label styled like the hint', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CustomTextField(
            title: const Text('Amount'),
            hint: '0',
            suffixText: r'$',
            controller: controller,
          ),
        ),
      ),
    );

    final hint = tester.widget<Text>(find.text('0'));
    final suffix = tester.widget<Text>(find.text(r'$'));
    expect(suffix.style?.color, hint.style?.color);
    expect(
      find.ancestor(
        of: find.text(r'$'),
        matching: find.byType(AnimatedOpacity),
      ),
      findsNothing,
    );

    await tester.enterText(find.byType(TextFormField), '250');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(find.text(r'$'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text(r'$'),
        matching: find.byType(AnimatedOpacity),
      ),
      findsNothing,
    );
  });
}
