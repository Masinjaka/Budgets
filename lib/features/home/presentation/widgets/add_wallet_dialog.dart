import 'package:budgets/widgets/custom_textfield.dart';
import 'package:budgets/features/home/domain/models/add_wallet_input.dart';
import 'package:flutter/material.dart';

class AddWalletDialog extends StatefulWidget {
  const AddWalletDialog({super.key});

  static Future<AddWalletInput?> show(BuildContext context) {
    return showDialog<AddWalletInput>(
      context: context,
      builder: (context) => const AddWalletDialog(),
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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            hint: 'e.g. Savings',
            height: 48,
            fontSize: 14,
            fillColor: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            key: const Key('wallet-balance-field'),
            controller: _balanceController,
            title: const Text(
              'Current balance',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            hint: '0 Ar',
            keyboardType: TextInputType.number,
            height: 48,
            fontSize: 14,
            fillColor: const Color(0xFFEEEEEE),
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
    final value = _balanceController.text.replaceAll(RegExp(r'[\s,]'), '');
    if (value.isEmpty) return 0;
    final amount = int.tryParse(value);
    return amount != null && amount >= 0 ? amount : null;
  }
}
