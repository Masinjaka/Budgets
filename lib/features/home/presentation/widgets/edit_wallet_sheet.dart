import 'package:budgets/core/currency/currency_amount_input.dart';
import 'package:budgets/core/currency/currency_amount_input_formatter.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:budgets/features/home/domain/models/wallet_editor_result.dart';
import 'package:budgets/features/home/domain/models/wallet_summary.dart';
import 'package:budgets/features/home/presentation/widgets/bottom_sheet_drag_handle.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class EditWalletSheet extends StatefulWidget {
  const EditWalletSheet({
    required this.wallet,
    this.currencyState,
    super.key,
  });

  final WalletSummary wallet;
  final CurrencyState? currencyState;

  static Future<WalletEditorResult?> show(
    BuildContext context, {
    required WalletSummary wallet,
    CurrencyState? currencyState,
  }) {
    return showModalBottomSheet<WalletEditorResult>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditWalletSheet(
        wallet: wallet,
        currencyState: currencyState,
      ),
    );
  }

  @override
  State<EditWalletSheet> createState() => _EditWalletSheetState();
}

class _EditWalletSheetState extends State<EditWalletSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  bool _canSubmit = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet.name);
    _balanceController = TextEditingController(
      text: CurrencyAmountInput.fromStored(
        widget.wallet.balance,
        widget.wallet.currencyCode,
        widget.currencyState,
      ),
    );
    _nameController.addListener(_validate);
    _balanceController.addListener(_validate);
  }

  void _validate() {
    final valid = _nameController.text.trim().isNotEmpty && _balance != null;
    if (valid != _canSubmit) setState(() => _canSubmit = valid);
  }

  void _save() {
    if (!_canSubmit) return;
    Navigator.pop(
      context,
      WalletEditorResult.save(
        AddWalletInput(
          name: _nameController.text.trim(),
          initialBalance: _balance ?? 0,
        ),
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
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
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
                  context.l10n.editWallet,
                  key: const Key('edit-wallet-sheet-title'),
                  style: const TextStyle(
                    fontSize: AppTypography.headline,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 17),
                _nameField(context),
                const SizedBox(height: 14),
                _balanceField(context),
                const SizedBox(height: 19),
                CustomButton(
                  key: const Key('save-wallet'),
                  text: context.l10n.save,
                  onPressed: _canSubmit ? _save : null,
                ),
                if (!widget.wallet.isDefault) ...[
                  const SizedBox(height: 10),
                  CustomButton.outlined(
                    key: const Key('delete-wallet'),
                    text: context.l10n.deleteWallet,
                    foregroundColor: Colors.red,
                    borderColor: Colors.red,
                    onPressed: () => Navigator.pop(
                      context,
                      const WalletEditorResult.delete(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameField(BuildContext context) => CustomTextField(
        key: const Key('edit-wallet-name-field'),
        controller: _nameController,
        title: Text(context.l10n.walletNameLabel, style: _labelStyle),
        hint: context.l10n.walletNameHint,
        fontSize: AppTypography.body,
        fillColor: Theme.of(context).cardColor,
      );

  Widget _balanceField(BuildContext context) => CustomTextField(
        key: const Key('edit-wallet-balance-field'),
        controller: _balanceController,
        title: Text(context.l10n.currentBalanceLabel, style: _labelStyle),
        hint: CurrencyAmountInput.hint(widget.currencyState),
        suffixText: CurrencyAmountInput.symbol(widget.currencyState),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: const [CurrencyAmountInputFormatter()],
        fontSize: AppTypography.body,
        fillColor: Theme.of(context).cardColor,
      );

  int? get _balance {
    final value = CurrencyAmountInput.toMga(
      _balanceController.text,
      widget.currencyState,
    );
    return value >= 0 ? value : null;
  }

  static const _labelStyle = TextStyle(
    fontSize: AppTypography.body,
    fontWeight: FontWeight.w700,
  );
}
