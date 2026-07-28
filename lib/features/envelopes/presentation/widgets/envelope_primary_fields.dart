import 'package:budgets/core/currency/currency_amount_input_formatter.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class EnvelopePrimaryFields extends StatelessWidget {
  const EnvelopePrimaryFields({
    required this.nameController,
    required this.amountController,
    required this.amountHint,
    required this.amountSuffix,
    super.key,
  });

  final TextEditingController nameController;
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
          title: Text(context.l10n.name, style: labelStyle),
          hint: context.l10n.envelopeNameHint,
          controller: nameController,
          fillColor: Theme.of(context).cardColor,
          fontSize: AppTypography.body,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          title: Text(context.l10n.monthlyAmount, style: labelStyle),
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
