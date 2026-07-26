import 'package:budgets/features/home/presentation/widgets/drawer_destination_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('skips return refresh after the user signs out', (tester) async {
    var signedIn = true;
    var refreshCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              key: const Key('open-settings'),
              onPressed: () => DrawerDestinationNavigator(
                context: context,
                selectedDate: DateTime(2026, 7, 22),
                closeDrawer: () {},
                onReturn: () async => refreshCount++,
                shouldRunOnReturn: () => signedIn,
              ).openSettings(),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    signedIn = false;
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(refreshCount, 0);
  });
}
