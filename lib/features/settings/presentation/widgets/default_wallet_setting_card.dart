import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/home/presentation/widgets/wallet_source_sheet.dart';
import 'package:budgets/features/settings/data/services/default_wallet_service.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DefaultWalletSettingCard extends StatefulWidget {
  const DefaultWalletSettingCard({this.service, super.key});

  final DefaultWalletService? service;

  @override
  State<DefaultWalletSettingCard> createState() =>
      _DefaultWalletSettingCardState();
}

class _DefaultWalletSettingCardState extends State<DefaultWalletSettingCard> {
  DefaultWalletService? _service;
  List<WalletSummary> _wallets = const [];

  WalletSummary? get _defaultWallet {
    for (final wallet in _wallets) {
      if (wallet.isDefault) return wallet;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    try {
      _service =
          widget.service ?? DefaultWalletService(Supabase.instance.client);
    } catch (_) {
      return;
    }
    _load();
  }

  Future<void> _load() async {
    try {
      final wallets = await _service?.wallets() ?? const <WalletSummary>[];
      if (mounted) setState(() => _wallets = wallets);
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  Future<void> _choose() async {
    if (_service == null || _wallets.isEmpty) return;
    final walletId = await WalletSourceSheet.show(
      context,
      wallets: _wallets,
      requiredAmount: 0,
      title: 'Default wallet',
      message: 'Expenses and new envelopes use this wallet by default.',
    );
    if (walletId == null) return;
    try {
      await _service!.setDefault(walletId);
      await _load();
      if (mounted) showSuccessToast(context, 'Default wallet updated.');
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingCard(
      title: 'Portefeuille par défaut',
      iconData: Icons.account_balance_wallet_outlined,
      onTap: _choose,
      showSuffixSettingChoice: true,
      settingChoice: _defaultWallet?.name ?? '...',
    );
  }
}
