import 'package:budgets/core/currency/currency_amount_input.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:flutter/material.dart';

class AddWalletDialog extends StatefulWidget {
  const AddWalletDialog({this.currencyState, super.key});

  final CurrencyState? currencyState;

  static Future<AddWalletInput?> show(
    BuildContext context, {
    CurrencyState? currencyState,
  }) {
    return showDialog<AddWalletInput>(
      context: context,
      builder: (context) => AddWalletDialog(currencyState: currencyState),
    );
  }

  @override
  State<AddWalletDialog> createState() => _AddWalletDialogState();
}

class _AddWalletDialogState extends State<AddWalletDialog> {
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
    return AlertDialog(
      title: const Text('Add wallet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            key: const Key('wallet-name-field'),
            controller: _nameController,
            title: const Text(
              'Wallet name',
              style: TextStyle(
                fontSize: AppTypography.body,
                fontWeight: FontWeight.w600,
              ),
            ),
            hint: 'e.g. Savings',
            fontSize: AppTypography.body,
            fillColor: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            key: const Key('wallet-balance-field'),
            controller: _balanceController,
            title: const Text(
              'Current balance',
              style: TextStyle(
                fontSize: AppTypography.body,
                fontWeight: FontWeight.w600,
              ),
            ),
            hint: CurrencyAmountInput.hint(widget.currencyState),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            fontSize: AppTypography.body,
            fillColor: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('confirm-add-wallet'),
          onPressed: _canSubmit ? _submit : null,
          child: const Text('Add'),
        ),
      ],
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
