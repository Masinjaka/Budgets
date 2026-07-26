import 'package:budgets/features/envelopes/domain/models/envelope_category.dart';
import 'package:budgets/features/envelopes/presentation/widgets/add_envelope_sheet.dart';
import 'package:budgets/features/home/presentation/widgets/bottom_sheet_drag_handle.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_category_field.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens as a manual-entry styled category sheet', (tester) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheetDragHandle), findsOneWidget);
    expect(find.byType(ManualEntryCategoryField), findsOneWidget);
    final card = find.byKey(const Key('manual-category-food'));
    final scale = find.ancestor(
      of: card,
      matching: find.byType(AnimatedScale),
    );
    expect(tester.widget<AnimatedScale>(scale).scale, 1);

    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(
      tester.widget<AnimatedScale>(scale).scale,
      ManualEntryCategoryField.selectedScale,
    );
  });
}

Widget _app() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => AddEnvelopeSheet.show(
            context,
            categories: const [_food],
            month: DateTime(2026, 7),
            onSave: (_, __, ___) async {},
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

const _food = EnvelopeCategory(
  id: 'food',
  name: 'Food',
  emoji: '🍔',
  color: 'FF888888',
);
