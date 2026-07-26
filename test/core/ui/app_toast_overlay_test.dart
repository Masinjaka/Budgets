import 'package:budgets/core/theme.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_toast_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bounces a compact toast in from the top and back out',
      (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              AppToastOverlay(
                message: 'Entry added.',
                color: Colors.green,
                icon: Icons.check,
                displayDuration: const Duration(milliseconds: 300),
                animationDuration: const Duration(milliseconds: 100),
                onDismissed: () => dismissed = true,
                onDisposed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final toast = find.byKey(const Key('app-toast'));
    expect(tester.getRect(toast).top, lessThan(12));

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 70));
    expect(tester.getRect(toast).top, greaterThan(12));
    await tester.pump(const Duration(milliseconds: 30));
    final toastRect = tester.getRect(toast);
    expect(toastRect.center.dx, 400);
    expect(toastRect.top, closeTo(12, 0.01));
    expect(toastRect.height, lessThan(50));
    final text = tester.widget<Text>(find.text('Entry added.'));
    expect(text.style?.decoration, TextDecoration.none);
    expect(text.style?.color, Colors.white);
    expect(tester.widget<Icon>(find.byIcon(Icons.check)).color, Colors.white);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 301));
    expect(find.byKey(const Key('app-toast-exit')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 40));
    expect(tester.getRect(toast).top, greaterThan(12));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump(const Duration(milliseconds: 1));

    expect(dismissed, isTrue);
  });

  testWidgets('uses the app green for success toasts', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSuccessToast(context, 'Saved.'),
            child: const Text('Show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();

    final container = tester.widget<Container>(
      find.byKey(const Key('app-toast')),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppTheme.primaryGreen);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpWidget(const SizedBox());
  });
}
