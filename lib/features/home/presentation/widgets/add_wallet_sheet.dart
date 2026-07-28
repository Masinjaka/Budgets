import 'package:budgets/core/currency/currency_amount_input.dart';
import 'package:budgets/core/currency/currency_amount_input_formatter.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/presentation/widgets/bottom_sheet_drag_handle.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class AddWalletSheet extends StatefulWidget {
  const AddWalletSheet({this.currencyState, super.key});

  final CurrencyState? currencyState;

  static Future<AddWalletInput?> show(
    BuildContext context, {
    CurrencyState? currencyState,
  }) {
    return showModalBottomSheet<AddWalletInput>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddWalletSheet(currencyState: currencyState),
    );
  }

  @override
  State<AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<AddWalletSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateCanSubmit);
    _balanceController.addListener(_updateCanSubmit);
  }

  void _updateCanSubmit() {
    final canSubmit =
        _nameController.text.trim().isNotEmpty && _initialBalance != null;
    if (canSubmit == _canSubmit) return;
    setState(() => _canSubmit = canSubmit);
  }

  void _submit() {
    if (!_canSubmit) return;
    Navigator.pop(
      context,
      AddWalletInput(
        name: _nameController.text.trim(),
        initialBalance: _initialBalance ?? 0,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    const labelStyle = TextStyle(
      fontSize: AppTypography.body,
      fontWeight: FontWeight.w700,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 13, 22, 18),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BottomSheetDragHandle(height: 7),
                const SizedBox(height: 20),
                Text(
                  context.l10n.addWallet,
                  key: const Key('add-wallet-sheet-title'),
                  style: const TextStyle(
                    fontSize: AppTypography.headline,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 17),
                CustomTextField(
                  key: const Key('wallet-name-field'),
                  controller: _nameController,
                  title: Text(
                    context.l10n.walletNameLabel,
                    style: labelStyle,
                  ),
                  hint: context.l10n.walletNameHint,
                  fontSize: AppTypography.body,
                  fillColor: Theme.of(context).cardColor,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  key: const Key('wallet-balance-field'),
                  controller: _balanceController,
                  title: Text(
                    context.l10n.currentBalanceLabel,
                    style: labelStyle,
                  ),
                  hint: CurrencyAmountInput.hint(widget.currencyState),
                  suffixText: CurrencyAmountInput.symbol(widget.currencyState),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const [CurrencyAmountInputFormatter()],
                  fontSize: AppTypography.body,
                  fillColor: Theme.of(context).cardColor,
                ),
                const SizedBox(height: 19),
                CustomButton(
                  key: const Key('confirm-add-wallet'),
                  text: context.l10n.addWallet,
                  onPressed: _canSubmit ? _submit : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int? get _initialBalance {
    if (_balanceController.text.trim().isEmpty) return 0;
    final amount = CurrencyAmountInput.toMga(
      _balanceController.text,
      widget.currencyState,
    );
    return amount >= 0 ? amount : null;
  }
}
