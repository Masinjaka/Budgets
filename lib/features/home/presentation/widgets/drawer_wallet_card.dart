import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/core/ui/privacy_text.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:flutter/material.dart';

class DrawerWalletCard extends StatelessWidget {
  const DrawerWalletCard({
    required this.wallet,
    this.currencyState,
    super.key,
  });

  final WalletSummary wallet;
  final CurrencyState? currencyState;

  static const size = Size(300, 165);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: Theme.of(context).cardColor,
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  wallet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppTypography.body,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          PrivacyText(
            _balanceLabel(wallet),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppTypography.title,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _balanceLabel(WalletSummary value) {
    final amount = currencyState?.convertToSelected(
          value.balance,
          value.currencyCode,
        ) ??
        value.balance;
    return formatAmountWithCurrency(
      amount,
      currencyState?.code ?? value.currencyCode,
      preserveFraction: true,
    );
  }
}
