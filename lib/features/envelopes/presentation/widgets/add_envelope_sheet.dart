import 'package:budgets/core/currency/currency_amount_input.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/envelopes/domain/models/envelope_category.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_category_field.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_primary_fields.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_sheet_header.dart';
import 'package:budgets/features/home/presentation/widgets/bottom_sheet_drag_handle.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AddEnvelopeSheet extends StatefulWidget {
  const AddEnvelopeSheet({
    required this.categories,
    required this.month,
    required this.onSave,
    this.currencyState,
    super.key,
  });

  final List<EnvelopeCategory> categories;
  final DateTime month;
  final Future<void> Function(String, String, int) onSave;
  final CurrencyState? currencyState;

  static Future<void> show(
    BuildContext context, {
    required List<EnvelopeCategory> categories,
    required DateTime month,
    required Future<void> Function(String, String, int) onSave,
    CurrencyState? currencyState,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEnvelopeSheet(
        categories: categories,
        month: month,
        onSave: onSave,
        currencyState: currencyState,
      ),
    );
  }

  @override
  State<AddEnvelopeSheet> createState() => _AddEnvelopeSheetState();
}

class _AddEnvelopeSheetState extends State<AddEnvelopeSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String? _categoryId;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = CurrencyAmountInput.toMga(
      _amountController.text,
      widget.currencyState,
    );
    final name = _nameController.text.trim();
    if (name.isEmpty || amount <= 0 || _categoryId == null) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(name, _categoryId!, amount);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
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
                EnvelopeSheetHeader(month: widget.month),
                const SizedBox(height: 17),
                EnvelopePrimaryFields(
                  nameController: _nameController,
                  amountController: _amountController,
                  amountHint: CurrencyAmountInput.hint(widget.currencyState),
                ),
                const SizedBox(height: 14),
                EnvelopeCategoryField(
                  categories: widget.categories,
                  value: _categoryId,
                  label: context.l10n.expenseCategory,
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                const SizedBox(height: 19),
                CustomButton(
                  key: const Key('save-envelope-button'),
                  text: context.l10n.create,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
