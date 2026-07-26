import 'package:budgets/core/theme.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_category_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the neutral surface and marks the selected card',
      (tester) async {
    String? selected;
    const category = ManualEntryCategory(
      id: 'housing',
      name: 'Housing',
      emoji: '🏠',
      transactionType: 'expense',
      colorHex: 'FFD8B4FE',
    );
    const darkCategory = ManualEntryCategory(
      id: 'transport',
      name: 'Transport',
      emoji: '🚌',
      transactionType: 'expense',
      colorHex: 'FF5B21B6',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ManualEntryCategoryField(
              categories: const [category, darkCategory],
              value: selected,
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );

    final card = find.descendant(
      of: find.byKey(const Key('manual-category-housing')),
      matching: find.byType(AnimatedContainer),
    );
    var decoration =
        tester.widget<AnimatedContainer>(card).decoration! as BoxDecoration;
    expect(
      tester.getSize(card),
      const Size(
        ManualEntryCategoryField.cardWidth,
        ManualEntryCategoryField.cardHeight,
      ),
    );
    final scale = find.ancestor(
      of: find.byKey(const Key('manual-category-housing')),
      matching: find.byType(AnimatedScale),
    );
    expect(tester.widget<AnimatedScale>(scale).scale, 1);
    expect(decoration.color, AppTheme.neutralSurface);
    expect(decoration.border?.top.color, Colors.transparent);
    final lightLabel = tester.widget<Text>(find.text('Housing')).style!;
    final darkLabel = tester.widget<Text>(find.text('Transport')).style!;
    expect(lightLabel.color, Colors.black);
    expect(lightLabel.fontWeight, FontWeight.w700);
    expect(lightLabel.shadows, isNull);
    expect(darkLabel.color, Colors.black);
    expect(darkLabel.fontWeight, FontWeight.w700);
    expect(darkLabel.shadows, isNull);
    final iconAlignment = find
        .descendant(
          of: find.byKey(const Key('manual-category-housing')),
          matching: find.byType(AnimatedAlign),
        )
        .first;
    final labelAlignment = find
        .descendant(
          of: find.byKey(const Key('manual-category-housing')),
          matching: find.byType(AnimatedAlign),
        )
        .last;
    expect(
      tester.widget<AnimatedAlign>(iconAlignment).alignment,
      Alignment.topLeft,
    );
    expect(
      tester.widget<AnimatedAlign>(labelAlignment).alignment,
      Alignment.bottomLeft,
    );

    await tester.tap(find.byKey(const Key('manual-category-housing')));
    await tester.pumpAndSettle();

    expect(selected, 'housing');
    decoration =
        tester.widget<AnimatedContainer>(card).decoration! as BoxDecoration;
    expect(
      decoration.border?.top.color,
      Color.lerp(AppTheme.neutralSurface, Colors.black, 0.32),
    );
    expect(
      tester.widget<AnimatedAlign>(iconAlignment).alignment,
      const Alignment(0, -0.35),
    );
    expect(
      tester.widget<AnimatedAlign>(labelAlignment).alignment,
      Alignment.bottomCenter,
    );
    expect(
      tester.widget<AnimatedScale>(scale).scale,
      ManualEntryCategoryField.selectedScale,
    );
  });
}
