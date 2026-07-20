import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/home/domain/models/wallet_funding_choice.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/home/presentation/widgets/multi_wallet_consent_sheet.dart';
import 'package:budgets/features/home/presentation/widgets/wallet_source_sheet.dart';
import 'package:flutter/material.dart';

class WalletFundingPrompt {
  const WalletFundingPrompt._();

  static Future<WalletFundingChoice?> show(
    BuildContext context, {
    required List<WalletSummary> wallets,
    required int requiredAmount,
  }) async {
    final eligible = wallets
        .where((wallet) => wallet.balance >= requiredAmount)
        .toList(growable: false);
    if (eligible.isNotEmpty) {
      final walletId = await WalletSourceSheet.show(
        context,
        wallets: wallets,
        requiredAmount: requiredAmount,
      );
      return walletId == null ? null : WalletFundingChoice.single(walletId);
    }

    final available = wallets.fold<int>(
      0,
      (total, wallet) => total + wallet.balance,
    );
    if (available < requiredAmount) {
      if (context.mounted) {
        showAppToast(
          context,
          'Insufficient funds across all wallets.',
          type: AppToastType.error,
        );
      }
      return null;
    }
    final accepted = await MultiWalletConsentSheet.show(
      context,
      requiredAmount: requiredAmount,
      availableAmount: available,
    );
    if (accepted) return const WalletFundingChoice.combined();
    if (context.mounted) {
      showAppToast(
        context,
        'Insufficient funds. The transaction was not completed.',
        type: AppToastType.error,
      );
    }
    return null;
  }
}
