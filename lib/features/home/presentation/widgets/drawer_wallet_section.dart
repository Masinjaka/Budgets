import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/home/domain/errors/wallet_deletion_exception.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/wallet_editor_result.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/home/presentation/widgets/add_wallet_sheet.dart';
import 'package:budgets/features/home/presentation/widgets/drawer_wallet_card.dart';
import 'package:budgets/features/home/presentation/widgets/edit_wallet_sheet.dart';
import 'package:budgets/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class DrawerWalletSection extends StatelessWidget {
  const DrawerWalletSection({
    required this.wallets,
    required this.onAddWallet,
    required this.onUpdateWallet,
    required this.onDeleteWallet,
    this.currencyState,
    this.isAdding = false,
    super.key,
  });

  final List<WalletSummary> wallets;
  final Future<void> Function(AddWalletInput input) onAddWallet;
  final Future<void> Function(String walletId, AddWalletInput input)
      onUpdateWallet;
  final Future<void> Function(String walletId) onDeleteWallet;
  final CurrencyState? currencyState;
  final bool isAdding;

  Future<void> _addWallet(BuildContext context) async {
    final input = await AddWalletSheet.show(
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

  Future<void> _editWallet(
    BuildContext context,
    WalletSummary wallet,
  ) async {
    final result = await EditWalletSheet.show(
      context,
      wallet: wallet,
      currencyState: currencyState,
    );
    if (result == null || !context.mounted) return;
    if (result.action == WalletEditorAction.delete) {
      await _deleteWallet(context, wallet);
      return;
    }
    try {
      await onUpdateWallet(wallet.id, result.input!);
      if (context.mounted) {
        showSuccessToast(context, context.l10n.walletUpdated);
      }
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
  }

  Future<void> _deleteWallet(
    BuildContext context,
    WalletSummary wallet,
  ) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: context.l10n.deleteWalletQuestion,
      message: context.l10n.deleteWalletDescription,
      confirmText: context.l10n.delete,
      cancelText: context.l10n.cancel,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await onDeleteWallet(wallet.id);
      if (context.mounted) {
        showSuccessToast(context, context.l10n.walletDeleted);
      }
    } on WalletDeletionException {
      if (context.mounted) {
        showAppToast(
          context,
          context.l10n.walletInUseCannotBeDeleted,
          type: AppToastType.error,
        );
      }
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
          height: 155,
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
                onTap: isAdding
                    ? null
                    : () => _editWallet(context, wallets[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
