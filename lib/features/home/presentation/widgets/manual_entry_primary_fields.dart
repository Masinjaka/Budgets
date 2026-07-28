import 'package:budgets/core/currency/currency_amount_input_formatter.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class ManualEntryPrimaryFields extends StatelessWidget {
  const ManualEntryPrimaryFields({
    required this.transactionType,
    required this.titleController,
    required this.amountController,
    required this.amountHint,
    required this.amountSuffix,
    super.key,
  });

  final String transactionType;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final String amountHint;
  final String amountSuffix;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: AppTypography.body,
      fontWeight: FontWeight.w700,
    );
    return Column(
      children: [
        CustomTextField(
          title: const Text('Title', style: labelStyle),
          hint: transactionType == 'expense' ? 'Coffee' : 'Salary',
          controller: titleController,
          fillColor: Theme.of(context).cardColor,
          fontSize: AppTypography.body,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          title: const Text('Amount', style: labelStyle),
          hint: amountHint,
          suffixText: amountSuffix,
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [CurrencyAmountInputFormatter()],
          fillColor: Theme.of(context).cardColor,
          fontSize: AppTypography.body,
        ),
      ],
    );
  }
}
