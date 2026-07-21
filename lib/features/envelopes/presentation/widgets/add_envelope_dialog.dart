import 'package:budgets/core/theme.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/envelopes/domain/models/envelope_category.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class AddEnvelopeDialog extends StatefulWidget {
  const AddEnvelopeDialog({
    required this.categories,
    required this.onSave,
    super.key,
  });

  final List<EnvelopeCategory> categories;
  final Future<void> Function(String, String, int) onSave;

  @override
  State<AddEnvelopeDialog> createState() => _AddEnvelopeDialogState();
}

class _AddEnvelopeDialogState extends State<AddEnvelopeDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  EnvelopeCategory? _category;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = parseAmountInput(_amountController.text).round();
    final category = _category;
    if (_nameController.text.trim().isEmpty ||
        amount <= 0 ||
        category == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(_nameController.text.trim(), category.id, amount);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);
    return AlertDialog(
      backgroundColor: const Color(0xFFFEFEFE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text(
        'New envelope',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              title: const Text('Name', style: labelStyle),
              hint: 'e.g. Groceries',
              controller: _nameController,
              borderRadius: BorderRadius.circular(14),
              fillColor: const Color(0xFFF0F0F0),
              fontSize: 14,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              title: const Text('Monthly amount', style: labelStyle),
              hint: '0 Ar',
              controller: _amountController,
              keyboardType: TextInputType.number,
              borderRadius: BorderRadius.circular(14),
              fillColor: const Color(0xFFF0F0F0),
              fontSize: 14,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<EnvelopeCategory>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: 'Expense category',
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              items: widget.categories
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text('${item.emoji}  ${item.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: AppTheme.interactiveTextColor,
          ),
          child: Text(_saving ? 'Saving…' : 'Create'),
        ),
      ],
    );
  }
}
