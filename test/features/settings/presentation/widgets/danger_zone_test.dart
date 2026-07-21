import 'package:budgets/features/settings/presentation/view_models/danger_zone_view_model.dart';
import 'package:budgets/features/settings/presentation/widgets/danger_zone.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../support/fake_account_data_repository.dart';

void main() {
  testWidgets('requires typed confirmation before deleting all data',
      (tester) async {
    final repository = FakeAccountDataRepository();
    final viewModel = DangerZoneViewModel(repository);
    addTearDown(viewModel.dispose);
    await _pumpDangerZone(tester, viewModel);

    expect(find.text('Zone de danger'), findsOneWidget);
    expect(find.text('Supprimer toutes mes données'), findsOneWidget);
    expect(find.text('Supprimer mon compte'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-all-data-button')));
    await tester.pumpAndSettle();
    expect(find.byType(CustomTextField), findsOneWidget);

    final confirmButton = tester
        .widget<FilledButton>(find.byKey(const Key('danger-confirm-button')));
    expect(confirmButton.onPressed, isNull);

    await tester.enterText(
      _confirmationField(),
      'SUPPRIMER',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('danger-confirm-button')));
    await tester.pumpAndSettle();

    expect(repository.dataConfirmation, 'SUPPRIMER');
  });

  testWidgets('requires the account email before deleting the account',
      (tester) async {
    final repository = FakeAccountDataRepository();
    final viewModel = DangerZoneViewModel(repository);
    addTearDown(viewModel.dispose);
    await _pumpDangerZone(tester, viewModel);

    await tester.tap(find.byKey(const Key('delete-account-button')));
    await tester.pumpAndSettle();
    expect(find.text('Saisissez owner@example.com pour confirmer.'),
        findsOneWidget);

    await tester.enterText(
      _confirmationField(),
      'owner@example.com',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('danger-confirm-button')));
    await tester.pumpAndSettle();

    expect(repository.accountConfirmation, 'owner@example.com');
  });
}

Finder _confirmationField() => find.descendant(
      of: find.byKey(const Key('danger-confirmation-field')),
      matching: find.byType(TextFormField),
    );

Future<void> _pumpDangerZone(
  WidgetTester tester,
  DangerZoneViewModel viewModel,
) =>
    tester.pumpWidget(
      ResponsiveSizer(
        builder: (_, __, ___) => MaterialApp(
          home: Scaffold(
            body: DangerZone(
              viewModel: viewModel,
              accountEmail: 'owner@example.com',
              onDataDeleted: () {},
              onAccountDeleted: () {},
            ),
          ),
        ),
      ),
    );
