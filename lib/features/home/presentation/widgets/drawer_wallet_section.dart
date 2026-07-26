import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/home/presentation/widgets/add_wallet_dialog.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class DrawerWalletSection extends StatelessWidget {
  const DrawerWalletSection({
    required this.wallets,
    required this.onAddWallet,
    this.currencyState,
    this.isAdding = false,
    super.key,
  });

  final List<WalletSummary> wallets;
  final Future<void> Function(AddWalletInput input) onAddWallet;
  final CurrencyState? currencyState;
  final bool isAdding;

  Future<void> _addWallet(BuildContext context) async {
    final input = await AddWalletDialog.show(
      context,
      currencyState: currencyState,
    );
    if (input == null || !context.mounted) return;
    try {
      await onAddWallet(input);
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 22, right: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${context.l10n.wallets} (${wallets.length})',
                  key: const Key('drawer-wallet-count'),
                  style: const TextStyle(
                    fontSize: AppTypography.body,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: isAdding ? null : () => _addWallet(context),
                icon: isAdding
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded, size: 23),
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                padding: EdgeInsets.zero,
                tooltip: context.l10n.addWallet,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.separated(
            key: const Key('wallet-card-list'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(22, 10, 14, 15),
            itemCount: wallets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return DrawerWalletCard(
                wallet: wallets[index],
                currencyState: currencyState,
              );
            },
          ),
        ),
      ],
    );
  }
}
