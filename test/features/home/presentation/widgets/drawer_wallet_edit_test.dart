import 'package:budgets/core/ui/amount_visibility_controller.dart';
import 'package:budgets/core/ui/amount_visibility_scope.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_wallet_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('edits and deletes a non-default wallet', (tester) async {
    final visibility = AmountVisibilityController();
    addTearDown(visibility.dispose);
    var wallets = [_wallet('cash', 'Cash', 400000, true), _bankWallet];

    await tester.pumpWidget(
      AmountVisibilityScope(
        controller: visibility,
        child: ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => DrawerWalletSection(
                  wallets: wallets,
                  onAddWallet: (_) async {},
                  onUpdateWallet: (id, input) async {
                    setState(() {
                      wallets = wallets
                          .map(
                            (wallet) => wallet.id == id
                                ? WalletSummary(
                                    id: id,
                                    name: input.name,
                                    balance: input.initialBalance,
                                    currencyCode: wallet.currencyCode,
                                    iconKey: wallet.iconKey,
                                    isDefault: wallet.isDefault,
                                  )
                                : wallet,
                          )
                          .toList();
                    });
                  },
                  onDeleteWallet: (id) async {
                    setState(() {
                      wallets =
                          wallets.where((wallet) => wallet.id != id).toList();
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await _showWalletEditor(tester, 'bank');
    expect(find.byKey(const Key('edit-wallet-sheet-title')), findsOneWidget);
    await tester.enterText(
      _field(const Key('edit-wallet-name-field')),
      'Daily account',
    );
    await tester.enterText(
      _field(const Key('edit-wallet-balance-field')),
      '750000',
    );
    await tester.ensureVisible(find.byKey(const Key('save-wallet')));
    await tester.tap(find.byKey(const Key('save-wallet')));
    await tester.pumpAndSettle();

    expect(find.text('Daily account'), findsOneWidget);
    expect(find.text('750 000 Ar'), findsOneWidget);

    await _showWalletEditor(tester, 'bank');
    await tester.ensureVisible(find.byKey(const Key('delete-wallet')));
    await tester.tap(find.byKey(const Key('delete-wallet')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this wallet?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Daily account'), findsNothing);
    expect(find.text('Wallets (1)'), findsOneWidget);
  });

  testWidgets('keeps delete unavailable for the default wallet', (
    tester,
  ) async {
    final visibility = AmountVisibilityController();
    addTearDown(visibility.dispose);
    await tester.pumpWidget(
      AmountVisibilityScope(
        controller: visibility,
        child: ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DrawerWalletSection(
                wallets: [_wallet('cash', 'Cash', 0, true)],
                onAddWallet: (_) async {},
                onUpdateWallet: (_, __) async {},
                onDeleteWallet: (_) async {},
              ),
            ),
          ),
        ),
      ),
    );

    await _showWalletEditor(tester, 'cash');
    expect(find.byKey(const Key('delete-wallet')), findsNothing);
  });
}

Future<void> _showWalletEditor(WidgetTester tester, String walletId) async {
  await tester.ensureVisible(find.byKey(Key('wallet-card-action-$walletId')));
  await tester.tap(find.byKey(Key('wallet-card-action-$walletId')));
  await tester.pumpAndSettle();
}

Finder _field(Key key) => find.descendant(
      of: find.byKey(key),
      matching: find.byType(TextFormField),
    );

const _bankWallet = WalletSummary(
  id: 'bank',
  name: 'Bank account',
  balance: 600000,
  currencyCode: 'MGA',
  iconKey: 'bank',
  isDefault: false,
);

WalletSummary _wallet(String id, String name, int balance, bool isDefault) =>
    WalletSummary(
      id: id,
      name: name,
      balance: balance,
      currencyCode: 'MGA',
      iconKey: 'wallet',
      isDefault: isDefault,
    );
