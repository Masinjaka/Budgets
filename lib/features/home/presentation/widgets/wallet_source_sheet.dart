import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/core/ui/privacy_text.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletSourceSheet extends StatelessWidget {
  const WalletSourceSheet({
    required this.wallets,
    required this.requiredAmount,
    this.title = 'Choose another wallet',
    this.message,
    super.key,
  });

  final List<WalletSummary> wallets;
  final int requiredAmount;
  final String title;
  final String? message;

  static Future<String?> show(
    BuildContext context, {
    required List<WalletSummary> wallets,
    required int requiredAmount,
    String title = 'Choose another wallet',
    String? message,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      builder: (_) => WalletSourceSheet(
        wallets: wallets,
        requiredAmount: requiredAmount,
        title: title,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('fr_FR');
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppTypography.title,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          PrivacyText(
            message ??
                'The transaction needs ${formatter.format(requiredAmount)}.',
            hiddenText: message ?? 'The transaction needs ***.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppTypography.body,
            ),
          ),
          const SizedBox(height: 14),
          ...wallets.map((wallet) {
            final enabled = wallet.balance >= requiredAmount;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: enabled,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).cardColor,
                child: Icon(
                  wallet.iconKey == 'bank'
                      ? Icons.account_balance_outlined
                      : Icons.account_balance_wallet_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              title: Text(wallet.name),
              subtitle: wallet.isDefault ? const Text('Default wallet') : null,
              trailing: PrivacyText(
                '${formatter.format(wallet.balance)} ${wallet.currencyCode}',
                style: TextStyle(
                  color: enabled
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: enabled ? () => Navigator.pop(context, wallet.id) : null,
            );
          }),
        ],
      ),
    );
  }
}
