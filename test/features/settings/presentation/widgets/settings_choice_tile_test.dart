import 'package:budgets/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('aligns a custom subtitle directly below its title',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsChoiceTile(
            title: 'Cash',
            leading: const Text('👛'),
            subtitleWidget: const Text(
              '400 000 Ar',
              key: Key('wallet-balance'),
            ),
            onTap: () {},
          ),
        ),
      ),
    );

    final titleBounds = tester.getRect(find.text('Cash'));
    final balanceBounds = tester.getRect(
      find.byKey(const Key('wallet-balance')),
    );

    expect(balanceBounds.left, titleBounds.left);
    expect(balanceBounds.top, greaterThan(titleBounds.bottom));
  });
}
