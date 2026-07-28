import 'package:budgets/core/ui/amount_visibility_controller.dart';
import 'package:budgets/core/ui/amount_visibility_scope.dart';
import 'package:budgets/features/home/domain/errors/wallet_deletion_exception.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_wallet_section.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the localized reason when a wallet is in use', (
    tester,
  ) async {
    final visibility = AmountVisibilityController();
    addTearDown(visibility.dispose);

    await tester.pumpWidget(
      AmountVisibilityScope(
        controller: visibility,
        child: ProviderScope(
          child: MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: DrawerWalletSection(
                wallets: const [_wallet],
                onAddWallet: (_) async {},
                onUpdateWallet: (_, __) async {},
                onDeleteWallet: (_) async {
                  throw const WalletDeletionException.inUse();
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('wallet-card-action-bank')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('delete-wallet')));
    await tester.tap(find.byKey(const Key('delete-wallet')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text(
        'Ce portefeuille contient un historique de transactions '
        'et ne peut pas être supprimé.',
      ),
      findsOneWidget,
    );
  });
}

const _wallet = WalletSummary(
  id: 'bank',
  name: 'Compte bancaire',
  balance: 600000,
  currencyCode: 'MGA',
  iconKey: 'bank',
  isDefault: false,
);
