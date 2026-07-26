import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/presentation/widgets/add_wallet_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('stores a selected-currency wallet balance as MGA',
      (tester) async {
    AddWalletInput? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await AddWalletDialog.show(
                  context,
                  currencyState: _usd,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text(r'$0'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Savings');
    await tester.enterText(find.byType(TextFormField).at(1), '200');
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirm-add-wallet')));
    await tester.pumpAndSettle();

    expect(result?.initialBalance, 1000000);
  });
}

const _usd = CurrencyState(
  code: 'USD',
  baseCode: 'MGA',
  rates: {'USD': 0.0002},
);
