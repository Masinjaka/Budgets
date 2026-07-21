import 'package:budgets/core/ui/app_toast_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('slides a compact toast in and out from the bottom right',
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

    final slide = find.byKey(const Key('app-toast-slide'));
    expect(tester.widget<SlideTransition>(slide).position.value.dx, 1.25);

    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<SlideTransition>(slide).position.value.dx, 0);
    final toastRect = tester.getRect(find.byKey(const Key('app-toast')));
    expect(toastRect.right, 788);
    expect(toastRect.bottom, 588);
    expect(toastRect.height, lessThan(50));

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.widget<SlideTransition>(slide).position.value.dx,
        greaterThan(0));
    await tester.pump(const Duration(milliseconds: 101));
    await tester.pump(const Duration(milliseconds: 1));

    expect(dismissed, isTrue);
  });
}
