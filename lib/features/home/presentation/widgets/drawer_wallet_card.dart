import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DrawerWalletCard extends StatelessWidget {
  const DrawerWalletCard({
    required this.wallet,
    super.key,
  });

  final WalletSummary wallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      height: 95,
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 13,
                backgroundColor: Color(0xFFEEEEEE),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.black,
                  size: 15,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  wallet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _balanceLabel(wallet),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF515151),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _balanceLabel(WalletSummary value) {
    final amount = NumberFormat('#,##0', 'en_US')
        .format(value.balance)
        .replaceAll(',', ' ');
    return value.currencyCode == 'MGA'
        ? '$amount Ar'
        : '$amount ${value.currencyCode}';
  }
}
