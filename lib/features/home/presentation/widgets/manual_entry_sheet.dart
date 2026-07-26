import 'package:budgets/core/currency/currency_amount_input.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';
import 'package:budgets/features/home/domain/models/manual_entry_sheet_result.dart';
import 'package:budgets/features/home/presentation/widgets/bottom_sheet_drag_handle.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_category_loader.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_primary_fields.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_sheet_actions.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_sheet_header.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_type_selector.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class ManualEntrySheet extends StatefulWidget {
  const ManualEntrySheet({
    required this.categories,
    required this.targetDate,
    this.currencyState,
    this.entry,
    super.key,
  });

  final Future<List<ManualEntryCategory>> categories;
  final DateTime targetDate;
  final CurrencyState? currencyState;
  final FinanceEntry? entry;
  static Future<ManualEntrySheetResult?> show(
    BuildContext context, {
    required Future<List<ManualEntryCategory>> categories,
    required DateTime targetDate,
    CurrencyState? currencyState,
    FinanceEntry? entry,
  }) =>
      showModalBottomSheet<ManualEntrySheetResult>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ManualEntrySheet(
          categories: categories,
          targetDate: targetDate,
          currencyState: currencyState,
          entry: entry,
        ),
      );

  @override
  State<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<ManualEntrySheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'expense';
  String? _categoryId;
  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry == null) return;
    _titleController.text = entry.title;
    _amountController.text = CurrencyAmountInput.fromStored(
      entry.amount,
      entry.currencyCode,
      widget.currencyState,
    );
    _descriptionController.text = entry.description;
    _type = entry.transactionType;
    _categoryId = entry.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _changeType(String type) {
    setState(() {
      _type = type;
      _categoryId = null;
    });
  }

  void _submit() {
    final amount = CurrencyAmountInput.toMga(
      _amountController.text,
      widget.currencyState,
    );
    if (_titleController.text.trim().isEmpty || amount <= 0) {
      showInfoToast(context, 'Enter a title and a positive amount.');
      return;
    }
    final occurredAt = widget.entry?.occurredAt ?? _targetDateTime();
    final input = ManualEntryInput(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: amount,
      transactionType: _type,
      categoryId: _categoryId,
      occurredAt: occurredAt,
      sourceWalletId: widget.entry?.sourceWalletId,
      useAllWallets: widget.entry?.usedMultipleWallets ?? false,
    );
    Navigator.of(context).pop(ManualEntrySheetResult.save(input));
  }

  void _delete() =>
      Navigator.of(context).pop(const ManualEntrySheetResult.delete());

  DateTime _targetDateTime() {
    final now = DateTime.now();
    return DateTime(
      widget.targetDate.year,
      widget.targetDate.month,
      widget.targetDate.day,
      now.hour,
      now.minute,
      now.second,
    );
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
                ManualEntrySheetHeader(
                  date: widget.targetDate,
                  isEditing: _isEditing,
                ),
                const SizedBox(height: 17),
                ManualEntryTypeSelector(
                  value: _type,
                  onChanged: _changeType,
                ),
                const SizedBox(height: 16),
                ManualEntryPrimaryFields(
                  transactionType: _type,
                  titleController: _titleController,
                  amountController: _amountController,
                  amountHint: CurrencyAmountInput.hint(widget.currencyState),
                ),
                const SizedBox(height: 14),
                ManualEntryCategoryLoader(
                  key: ValueKey('manual-category-$_type'),
                  categories: widget.categories,
                  transactionType: _type,
                  value: _categoryId,
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  title: const Text('Note (optional)', style: labelStyle),
                  hint: 'Add a short note',
                  controller: _descriptionController,
                  fillColor: Theme.of(context).cardColor,
                  fontSize: AppTypography.body,
                ),
                const SizedBox(height: 19),
                ManualEntrySheetActions(
                  isEditing: _isEditing,
                  onSave: _submit,
                  onDelete: _delete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
