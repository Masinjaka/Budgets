import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/core/ui/privacy_text.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/settings/data/services/default_wallet_service.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_menu_group.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_page_shell.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DefaultWalletPage extends ConsumerStatefulWidget {
  const DefaultWalletPage({this.service, super.key});

  final DefaultWalletService? service;

  @override
  ConsumerState<DefaultWalletPage> createState() => _DefaultWalletPageState();
}

class _DefaultWalletPageState extends ConsumerState<DefaultWalletPage> {
  late final DefaultWalletService _service =
      widget.service ?? DefaultWalletService(Supabase.instance.client);
  List<WalletSummary>? _wallets;
  String? _pendingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final wallets = await _service.wallets();
      if (mounted) setState(() => _wallets = wallets);
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  Future<void> _select(WalletSummary wallet) async {
    if (_pendingId != null || wallet.isDefault) return;
    setState(() => _pendingId = wallet.id);
    try {
      await _service.setDefault(wallet.id);
      await _load();
      if (mounted) {
        showSuccessToast(context, context.l10n.defaultWalletUpdated);
      }
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _pendingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCurrency = ref.watch(currencyControllerProvider).value;
    return SettingsPageShell(
      title: context.l10n.setDefaultWallet,
      child: _wallets == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              children: [
                Text(
                  context.l10n.defaultWalletDescription,
                  style: TextStyle(
                    fontSize: AppTypography.body,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 20),
                SettingsMenuGroup(
                  items: _wallets!
                      .map(
                        (wallet) => SettingsChoiceTile(
                          title: wallet.name,
                          subtitleWidget: PrivacyText(
                            formatAmountWithCurrency(
                              displayCurrency?.convertToSelected(
                                    wallet.balance,
                                    wallet.currencyCode,
                                  ) ??
                                  wallet.balance,
                              displayCurrency?.code ?? wallet.currencyCode,
                              preserveFraction: true,
                            ),
                            style: const TextStyle(
                              fontSize: AppTypography.supporting,
                            ),
                          ),
                          leading:
                              const Text('👛', style: TextStyle(fontSize: 20)),
                          trailing: _trailing(wallet),
                          onTap: () => _select(wallet),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }

  Widget? _trailing(WalletSummary wallet) {
    if (_pendingId == wallet.id) {
      return const SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return wallet.isDefault
        ? const Icon(Icons.check_circle, color: Colors.green)
        : null;
  }
}
