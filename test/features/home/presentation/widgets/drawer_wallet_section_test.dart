import 'package:budgets/core/ui/amount_visibility_controller.dart';
import 'package:budgets/core/ui/amount_visibility_scope.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_wallet_section.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_wallet_card.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows current wallets and adds a new wallet', (tester) async {
    final visibilityController = AmountVisibilityController();
    addTearDown(visibilityController.dispose);
    var wallets = [
      _wallet('cash', 'Cash', 400000),
      _wallet('bank', 'Bank account', 600000),
    ];
    await tester.pumpWidget(
      AmountVisibilityScope(
        controller: visibilityController,
        child: ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => SizedBox(
                  width: 360,
                  child: DrawerWalletSection(
                    wallets: wallets,
                    onAddWallet: (input) async {
                      setState(() {
                        wallets = [
                          ...wallets,
                          _wallet(
                            input.name,
                            input.name,
                            input.initialBalance,
                          ),
                        ];
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Wallets (2)'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('400 000 Ar'), findsOneWidget);
    expect(find.text('Bank account'), findsOneWidget);
    expect(find.text('600 000 Ar'), findsWidgets);
    expect(
      tester.getSize(find.byType(DrawerWalletCard).first),
      DrawerWalletCard.size,
    );
    expect(DrawerWalletCard.size, const Size(300, 165));

    visibilityController.toggle();
    await tester.pumpAndSettle();
    expect(find.text('***'), findsNWidgets(2));
    expect(find.text('400 000 Ar'), findsNothing);
    visibilityController.toggle();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add wallet'));
    await tester.pumpAndSettle();
    expect(find.text('Add wallet'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('wallet-name-field')),
        matching: find.byType(TextFormField),
      ),
      'Savings',
    );
    await tester.pump();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('wallet-balance-field')),
        matching: find.byType(TextFormField),
      ),
      '250000',
    );
    await tester.tap(find.byKey(const Key('confirm-add-wallet')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Savings'),
      150,
      scrollable: find.descendant(
        of: find.byKey(const Key('wallet-card-list')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('250 000 Ar'), findsOneWidget);
    expect(find.text('Wallets (3)'), findsOneWidget);
  });
}

WalletSummary _wallet(String id, String name, int balance) => WalletSummary(
      id: id,
      name: name,
      balance: balance,
      currencyCode: 'MGA',
      iconKey: 'wallet',
      isDefault: id == 'cash',
    );
